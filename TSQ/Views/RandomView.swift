//
//  Random.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/1/23.
//iosexample.com/fortune-spinning-wheel-library-built-using-swiftui-supports-dynamic-content/

import FirebaseFirestoreSwift
import SwiftUI
import FortuneWheel



struct RandomView: View {
    @StateObject var viewModel = RandomViewModel()
    @State var selectedIndex: Int = 0
    @State private var showMessage = false
    @State var id: String
    @State var refreshTrigger = false
    @State var lastCount: Int = 0
    @State private var selection: pick = .Tasks
    @State var toggleCamera = false

    
    enum pick: String, CaseIterable {
        case Tasks = "Tasks"
        case SideQuests = "SideQuests"
    }
    
    init(userId: String){
        id = userId
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Swipe to Spin!").font(.title).bold().offset(y:40)
                Spacer()
                if !viewModel.titleList.isEmpty {
                    ZStack {
                        Button("Double Tap me to Reset"){
                            refreshTrigger.toggle()
                        }
                        if refreshTrigger && lastCount == viewModel.titleList.count {
                            FortuneWheel(titles: viewModel.titleListShort, size: 320,onSpinEnd: { index in
                                selectedIndex = index
                                showMessage = true
                            })
                        }
                        if showMessage {
                            cardView(text: viewModel.titleList[selectedIndex])
                            HStack{
                                ButtonView(title:"ok", backroundColor: Color(UIColor(named: "darkBlue")!)){
                                    showMessage = false
                                }.frame(width: 110, height: 60)
                                    .offset(y:200)
                                Button{
                                    showMessage = false
                                    toggleCamera = true
                                } label:{
                                    ZStack{
                                        Rectangle().cornerRadius(10).frame(width: 80,height: 30)
                                            .foregroundColor(Color(UIColor(named: "darkBlue")!))
                                        Image(systemName: "camera")
                                            .foregroundColor(.white)
                                    }
                                }
                                .offset(y:200)
                            }
                        }
                    }
                    .padding()
                } else {
                    if (viewModel.titleList.count==0){
                        Text("Please add tasks or sidequests to access the randomizer").font(.subheadline).padding()
                    }
                    ProgressView()
                }
                Spacer()
                Picker("",selection: $selection){
                    ForEach(pick.allCases, id: \.self){
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color.white)
            }
            .navigationTitle("Random")
            .background(Image("circus").resizable().frame(width: 600,height: 900).offset(y:-70))
            .onAppear {
                viewModel.getData(userId: id)
                if lastCount == viewModel.titleList.count {
                    refreshTrigger = true
                }
                lastCount = viewModel.titleList.count
                
            }
            .onChange(of: viewModel.titleList.count) { _ in
                refreshTrigger.toggle()
            }
            .id(refreshTrigger)
            .onChange(of: selection) { newValue in
                viewModel.toggle.toggle()
                refreshTrigger = false
            }
            .sheet(isPresented: $toggleCamera) {
                CameraLayoutView(challenge:$viewModel.titleList[selectedIndex])
                        .frame(width: 390, height: 790)
                        .offset(y:20)
            }
        }
    }
}


struct Random_Previews: PreviewProvider {
    static var previews: some View {
        RandomView(userId: "ZQhOQS6ofvfq7rY0SnX1dhFn9qx1")
    }
}
