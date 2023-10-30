//
//  SQView.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/1/23.
//

import SwiftUI
import FirebaseFirestoreSwift

struct SQView: View {
    @ObservedObject var GPTViewModel = ChatGPTViewModel()
    @State var text = ""
    @State var models = [String]()
    @StateObject var viewModel: SQViewModel
    @FirestoreQuery var items: [SQItem]
    @FirestoreQuery var done: [SQItem]
    @State var counter: Double = 0.0
    @State var alert: Bool = false
    @State var toggleCamera = false
    @State var title = ""

    init(userId: String){
        self._items = FirestoreQuery(collectionPath: "users/\(userId)/SideQuests")
        self._done = FirestoreQuery(collectionPath: "users/\(userId)/doneChallenges")
        self._viewModel = StateObject(wrappedValue: SQViewModel(userId: userId))
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Spacer()
                ButtonView(title: "Add SideQuests", backroundColor: .blue){
                    viewModel.showingNewItemView = true
                }.frame(height: 100)
                .sheet(isPresented: $viewModel.showingNewItemView){
                    NewItemSQView(newItemPresented: $viewModel.showingNewItemView)
                        .presentationDetents([.height(220)])
                }
                let a = items.sorted(by: { $0.createDate > $1.createDate })
                Spacer()
                List{
                    ForEach(a) { item in
                        Text(item.title)
                            .listRowBackground(
                                Color.white.opacity(1 - Double(a.firstIndex(where: {$0.title == item.title})!)*0.08)
                                    .cornerRadius(15))
                            .swipeActions() {
                                Button("Delete") {
                                    viewModel.delete(id: item.id)
                                }
                                .tint(.red)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .swipeActions(edge: .leading) {
                                Button("Done") {
                                    viewModel.doneChallenges(title: item.title)
                                    viewModel.delete(id: item.id)
                                }
                                .tint(.blue)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onTapGesture(count:2) {
                                title = item.title
                                toggleCamera.toggle()
                            }
                    }
                }
                .listStyle(PlainListStyle())
                .sheet(isPresented: $toggleCamera) {
                    CameraLayoutView(challenge:$title)
                            .frame(width: 390, height: 790)
                            .offset(y:20)
                }

                HStack {
                    TextField("Type a theme and your location...", text: $text)
                    Button("Send\(Image(systemName: "paperplane"))") {
                        send()
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .padding(20)
                .frame(minWidth: 300, maxWidth: 400, minHeight: 30, maxHeight: 30)
                .background(Color.white)
            }
            .navigationTitle("SideQuests")
            .background(Image("minimalistPark").offset(y:-130))
        }
        .onAppear {
            GPTViewModel.setUp(done: done)
        }
        .alert(Text("Please write a theme, the more specific the better! Examples are: Fun activities in the city, Beach Challenges with friends, or Random!"), isPresented: $alert) {
        }
        
    }

    func send() {
        let newItemViewModel = NewSQViewModel()
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            alert.toggle()
            return
        }
        GPTViewModel.send(text: text) { response in
            DispatchQueue.main.async {
                let a = response.components(separatedBy: "\n")
                for i in 1..<a.count {
                        self.models.append(String(a[i].dropFirst(3)))
                }
                for i in 0..<self.models.count{
                    newItemViewModel.title = models[i]
                    newItemViewModel.save()
                }
                print(response)
                self.text = ""
                self.models = []
            }
        }
    }
}


struct SQView_Previews: PreviewProvider {
    static var previews: some View {
        SQView(userId: "ZQhOQS6ofvfq7rY0SnX1dhFn9qx1")
    }
}
