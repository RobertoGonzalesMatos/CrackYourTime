//
//  TasksView.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/30/23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct TasksView: View {
    @StateObject var viewModel: TaskViewModel
    @StateObject var shareViewModel = ShareViewModel()
    @State private var drawShowing: Bool = false
    @State private var shareShowing: Bool = false
    @FirestoreQuery var items: [TasksItem]

    init(userId: String){
        self._items = FirestoreQuery(collectionPath: "users/\(userId)/tasks")
        self._viewModel = StateObject(wrappedValue: TaskViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationView{
            VStack{
                Spacer()
                List(items){
                    item in
                    TaskItemView(item: item)
                        .swipeActions(){
                            Button("Delete"){
                                viewModel.delete(id: item.id)
                            }
                            .tint(.red)
                        }
                        .swipeActions(edge: .leading){
                            Button("Share"){
                                shareShowing = true
                                shareViewModel.setUp(item: item)
                            }
                            .tint(.blue)
                        }
                        .listRowBackground(
                            Color.white.opacity(0.8).cornerRadius(15))

                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Tasks")
            .background(Image("Image").resizable().frame(width: 600,height: 800).offset(y:-100))
            .toolbar{
                Button{
                    drawShowing = true
                }
            label:{
                    ZStack{
                        Rectangle().cornerRadius(15).frame(width: 40,height: 40)
                            .foregroundColor(.white)
                            .opacity(1)
                        Image(systemName: "pencil")
                    }
                }
                Button{
                    viewModel.showingNewItemView = true
                } label:{
                    ZStack{
                        Rectangle().cornerRadius(15).frame(width: 40,height: 40)
                            .foregroundColor(.white)
                            .opacity(1)
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingNewItemView){
                NewItemView(newItemPresented: $viewModel.showingNewItemView)
                    .presentationDetents([.height(650)])
            }
            .sheet(isPresented: $drawShowing){
                DrawView(id: "ZQhOQS6ofvfq7rY0SnX1dhFn9qx1")
                    .presentationDetents([.height(650)])
            }
            .sheet(isPresented: $shareShowing){
                ShareView(viewModel: shareViewModel)
                    .presentationDetents([.height(240)])
            }
        }
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView(userId: "ZQhOQS6ofvfq7rY0SnX1dhFn9qx1")
    }
}
