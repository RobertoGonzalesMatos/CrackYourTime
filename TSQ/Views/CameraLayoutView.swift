//
//  CameraView.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/12/23.
//

import SwiftUI
import AVKit

struct CameraLayoutView: View {
    @State var showPreview:Bool = false
    @ObservedObject var cameraModel:  CameraViewModel = CameraViewModel(output: .init())
    @State var duration: CGFloat = 0.0
    @State var save: Bool = false
    @State var load: Bool = false
    @Binding var challenge: String

    var body: some View {
        ZStack(alignment: .bottom){
            CameraView(cameraModel: cameraModel, duration: $duration)
                .clipShape(RoundedRectangle(cornerRadius: 30,style: .continuous))
                .padding(.top,10)
                .padding(.bottom,30)
                .onAppear(){
                    cameraModel.addText(title: challenge)
                }
            
            ZStack{
                Button {
                    if cameraModel.isRecording {
                        cameraModel.stopRecording()
                    } else {
                        cameraModel.startRecording()
                    }
                } label: {
                    Image("reels")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.black)
                        .opacity(cameraModel.isRecording ? 0:1)
                        .padding(12)
                        .frame(width: 60, height: 60)
                        .background{
                            Circle()
                                .stroke(cameraModel.isRecording ? .clear : .black)
                        }
                        .padding(6)
                        .background{
                            Circle()
                                .fill(cameraModel.isRecording ? .red:.white)
                        }
                }
                Button {
                    if let _ = cameraModel.previewURL{
                        showPreview.toggle()
                    }
                } label: {
                    Group{
                        if cameraModel.loading {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Label {
                                Image(systemName: "chevron.right")
                                    .font(.callout)
                            } icon: {
                                Text("Preview")
                            }
                            .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal,20)
                    .padding(.vertical,8)
                    .background{
                        Capsule()
                            .fill(.white)
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom,10)
            .padding(.bottom,30)
            
            Button {
                cameraModel.recordedDuration = 0
                duration = 0
                cameraModel.previewURL = nil
                cameraModel.recordedURLs.removeAll()
            } label: {
                Image(systemName: "xmark")
                    .font(.title)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity,maxHeight:.infinity,alignment: .topLeading)
            .padding()
            .padding(.top)
            Button {
                cameraModel.changeCamera()
            } label: {
                Image(systemName: "camera.rotate.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity,maxHeight:.infinity,alignment: .topTrailing)
            .padding()
            .padding(.top)
            
        }
        .overlay(content: {
            if let url = cameraModel.previewURL, showPreview {
                FinalPreview(url: url, showPreview: $showPreview, save: $save)
                    .transition(.move(edge: .trailing))
            }
        })
        .animation(.easeInOut, value: showPreview)
        .preferredColorScheme(.dark)
    }
}

struct CameraLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        CameraLayoutView(challenge: .constant("a"))
    }
}

struct FinalPreview: View {
    var url: URL
    @Binding var showPreview: Bool
    @Binding var save: Bool
    
    var body: some View {
        GeometryReader{proxy in
            let size = proxy.size
            
            VideoPlayer(player: AVPlayer(url: url))
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipShape(RoundedRectangle(cornerRadius: 30,style: .continuous))
                .overlay(alignment: .topLeading) {
                    Button {
                        showPreview.toggle()
                    } label: {
                        Label {
                            Text("Back")
                        } icon: {
                            Image(systemName: "chevron.left")
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.leading)
                    .padding(.top,22)
                    ShareLink(item:url)
                        .offset(x:300,y: 10)
            }
        }
    }
}
