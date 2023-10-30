//
//  CameraViewModel.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/12/23.
//

import Foundation
import AVFoundation
import SwiftUI

class CameraViewModel: NSObject,ObservableObject,AVCaptureFileOutputRecordingDelegate{
    
    @Published var output: AVCaptureMovieFileOutput = .init()
    @Published var isRecording: Bool = false
    @Published var recordedURLs: [URL] = []
    @Published var previewURL: URL?
    @Published var recordedDuration: CGFloat = 0
    @Published var maxDuration: CGFloat = 20
    @Published var session:  AVCaptureSession = .init()
    @Published var cameraPermission: Permissions = .idel
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var frontCam: Bool = false
    @Published var lastInput: AVCaptureDeviceInput?
    @Published var loading: Bool = false
    @Published var textOverlay: String = ""
    
    func addText(title: String){
        self.textOverlay = title
    }
    
    func checkPermission(){
        Task{
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case.authorized:
                DispatchQueue.main.async {
                    self.cameraPermission = .approved
                }
                setUpCamera()
            case.notDetermined:
                if await AVCaptureDevice.requestAccess(for: .video){
                    cameraPermission = .approved
                    setUpCamera()
                } else {
                    cameraPermission = .denied
                    presentErrorMessage("Please Provide Camera Access")
                }
            case.denied,.restricted:
                cameraPermission = .denied
                presentErrorMessage("Please Provide Camera Access")
            default:break
            }
        }
    }
    func setUpCamera(){
        do{
            guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInUltraWideCamera], mediaType: .video, position: .back).devices.first else {
                presentErrorMessage("UNKNOWN ERROR")
                return
            }
            let input = try AVCaptureDeviceInput(device: device)
            DispatchQueue.main.async {
                self.lastInput = input
            }
            guard session.canAddInput(input), session.canAddOutput(output) else {
                presentErrorMessage("UNKNOWN ERROR")
                return
            }
            guard let audioDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone], mediaType: .audio, position: .unspecified).devices.first else {
                presentErrorMessage("UNKNOWN ERROR")
                return
            }
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            guard session.canAddInput(audioInput), session.canAddOutput(output) else {
                presentErrorMessage("UNKNOWN ERROR")
                return
            }
            session.beginConfiguration()
            session.addInput(input)
            session.addInput(audioInput)
            session.addOutput(output)
            session.commitConfiguration()
            session.startRunning()
        }
        catch{
            presentErrorMessage(error.localizedDescription)
        }
    }
    
    func changeCamera(){
        if !isRecording{
            session.beginConfiguration()
            session.removeInput(lastInput!)
            do {
                if frontCam {
                    guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInUltraWideCamera], mediaType: .video, position: .back).devices.first else {
                        presentErrorMessage("UNKNOWN ERROR")
                        return
                    }
                    let input = try AVCaptureDeviceInput(device: device)
                    lastInput = input
                    guard session.canAddInput(input)else {
                        presentErrorMessage("UNKNOWN ERROR")
                        return
                    }
                    session.addInput(input)
                } else {
                    guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera], mediaType: .video, position: .front).devices.first else {
                        presentErrorMessage("UNKNOWN ERROR")
                        return
                    }
                    let input = try AVCaptureDeviceInput(device: device)
                    lastInput = input
                    guard session.canAddInput(input)else {
                        presentErrorMessage("UNKNOWN ERROR")
                        return
                    }
                    session.addInput(input)
                }
                session.commitConfiguration()
                frontCam.toggle()
            }
            catch {
                presentErrorMessage(error.localizedDescription)
            }
        }
    }
    
    func presentErrorMessage(_ message: String){
        errorMessage = message
        showError.toggle()
    }
    
    init(output: AVCaptureMovieFileOutput){
        self.output = output
    }
    func startRecording(){
        let tempURL = NSTemporaryDirectory() + "\(Date()).mov"
        output.startRecording(to: URL(filePath: tempURL), recordingDelegate: self)
        isRecording = true
    }
    
    func stopRecording(){
        output.stopRecording()
        isRecording = false
        loading = true
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print(error)
            return
        }
//        print(outputFileURL)
        self.recordedURLs.append(outputFileURL)
//        if self.recordedURLs.count == 1 {
//            self.previewURL = outputFileURL
//            loading = false
//            return
//        }
        
        let assets = recordedURLs.compactMap { url -> AVURLAsset in
            return AVURLAsset(url: url)
        }
        
        self.previewURL = nil
        
        Task{
            await mergeVideos(assets: assets) { exporter in
                exporter.exportAsynchronously {
                    if exporter.status == .failed {
                        print(exporter.error!)
                    }
                    else{
                        if let finalUrl = exporter.outputURL{
//                            print(finalUrl)
                            DispatchQueue.main.async {
                                self.previewURL = finalUrl
                                self.loading = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    func mergeVideos(assets: [AVURLAsset], completion: @escaping(_ exporter: AVAssetExportSession)->()) async{
        let composition = AVMutableComposition()
        var lastTime: CMTime = .zero
        
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {
            return
        }
        guard let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {
            return
        }
        
        for asset in assets {
            do{
                try await videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.load(.duration)), of: asset.loadTracks(withMediaType: .video)[0], at: lastTime)
                let assetTrack = try await asset.loadTracks(withMediaType: .video)
                if !assetTrack.isEmpty{
                    try await audioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.load(.duration)), of: asset.loadTracks(withMediaType: .audio)[0], at: lastTime)
                }
            }
            catch{
                print(error.localizedDescription)
            }
            
            do{
                try lastTime = await CMTimeAdd(lastTime, asset.load(.duration))
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory() + "Reel-\(Date()).mp4")
        
        let layerInstructions = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        
        var transform = CGAffineTransform.identity
        transform = transform.rotated(by: 90*(.pi/180))
        transform = transform.translatedBy(x: 0, y: -videoTrack.naturalSize.height)
        layerInstructions.setTransform(transform, at: .zero)
        
        let instructions = AVMutableVideoCompositionInstruction()
        instructions.timeRange = CMTimeRange(start: .zero, duration: lastTime)
        instructions.layerInstructions = [layerInstructions]
        
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
        videoComposition.instructions = [instructions]
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        
        if textOverlay != "" {
            let textLayer = CATextLayer()
            textLayer.string = textOverlay
            textLayer.fontSize = 50
            textLayer.alignmentMode = .center
            textLayer.isWrapped = true
            
            // Calculate the required height for the rectangle based on wrapped text
            let maxWidth: CGFloat = 740 // Adjust this value as needed
            let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 50)]
            let wrappedText = textOverlay as NSString
            let textRect = wrappedText.boundingRect(with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                                                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                    attributes: textAttributes,
                                                    context: nil)
            
            // Add padding to the calculated height for spacing
            let padding: CGFloat = 20 // Adjust this value as needed
            let rectangleHeight = textRect.height + padding * 2
            
            // Create the rounded rectangle shape layer
            let shapeLayer = CAShapeLayer()
            let roundedRect = CGRect(x: 150, y: 1500, width: 800, height: rectangleHeight)
            let cornerRadius: CGFloat = 20
            let path = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = UIColor.black.cgColor
            shapeLayer.opacity = 0.7
            textLayer.frame = CGRect(x: roundedRect.origin.x,
                                     y: roundedRect.origin.y-20,
                                     width: roundedRect.width,
                                     height: roundedRect.height)
            
            // Create an animation layer containing the text and shape layers
            let animationLayer = CALayer()
            animationLayer.frame = CGRect(origin: .zero, size: videoComposition.renderSize)
            animationLayer.addSublayer(textLayer)
            animationLayer.insertSublayer(shapeLayer, below: textLayer)
            
            let videoLayer = CALayer()
            videoLayer.frame = CGRect(origin: .zero, size: videoComposition.renderSize)
            videoLayer.addSublayer(animationLayer)

            let parentLayer = CALayer()
            parentLayer.frame = CGRect(origin: .zero, size: videoComposition.renderSize)
            parentLayer.addSublayer(videoLayer)

            let animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
            videoComposition.animationTool = animationTool
        }
                
        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            return
        }
        exporter.outputFileType = .mp4
        exporter.outputURL = tempURL
        exporter.videoComposition = videoComposition
        completion(exporter)
    }
}
