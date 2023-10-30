//
//  CameraView.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/12/23.
//

import SwiftUI
import AVKit

struct CameraView: View {
    @State var cameraModel:  CameraViewModel
    @Environment(\.openURL) private var openURL
    @Binding var duration: CGFloat
    var body: some View {
        GeometryReader{proxy in
            let size = proxy.size
            CameraPreviewView(session: $cameraModel.session, frameSize: size)
            
            ZStack(alignment: .leading){
                Rectangle()
                    .fill(.black.opacity(0.25))
                
                Rectangle()
                    .fill(Color("reelsColor"))
                    .frame(width: CGFloat(size.width)*(duration/cameraModel.maxDuration))
                
            }
            .frame(height: 8)
            .frame(maxHeight: .infinity,alignment: .top)
        }
        .onAppear(perform: {cameraModel.checkPermission()})
        .alert(cameraModel.errorMessage,isPresented: $cameraModel.showError) {
            if cameraModel.cameraPermission == .denied {
                Button("Settings"){
                    let settingsString = UIApplication.openSettingsURLString
                    if let settingsURL = URL(string:settingsString){
                        openURL(settingsURL)
                    }
                }
                Button("Cancel", role: .cancel){}
            }
        }
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
            if cameraModel.recordedDuration <= cameraModel.maxDuration && cameraModel.isRecording {
                withAnimation {
                    cameraModel.recordedDuration += 0.01
                    duration += 0.01
                }
//                print(cameraModel.recordedDuration/cameraModel.maxDuration)
            }
            
            if cameraModel.recordedDuration >= cameraModel.maxDuration && cameraModel.isRecording {
                cameraModel.stopRecording()
                cameraModel.isRecording = false
            }
        }

    }

}

struct CameraPreviewView: UIViewRepresentable {
    @Binding var session: AVCaptureSession
    var frameSize:CGSize

    func makeUIView(context: Context) -> UIView {
        let view = UIViewType(frame: CGRect(origin: .zero, size: frameSize))
        view.backgroundColor = .clear
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = .init(origin: .zero, size: frameSize)
        previewLayer.masksToBounds = true
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the view if needed
    }
}
