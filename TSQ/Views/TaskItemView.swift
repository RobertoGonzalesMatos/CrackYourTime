//
//  TaskItemView.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/30/23.
//

import SwiftUI

struct TaskItemView: View {
    
    @StateObject var viewModel = TaskItemViewModel()
    
    let item: TasksItem
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(item.title)
                    .font(.body)
                Text("\(Date(timeIntervalSince1970: item.dueDate).formatted(date: .abbreviated, time: .shortened))")
                    .font(.footnote)
                    .foregroundColor(Color(UIColor(named: "darkGray")!))
            }
            
            Spacer()
            
            Button{
                viewModel.toggleIsDone(item: item)
            } label:{
                Image(systemName: item.isDone ? "checkmark.circle.fill": "circle")
                    .foregroundColor(.blue)
            }
        }
    }
}

struct TaskItemView_Previews: PreviewProvider {
    static var previews: some View {
        TaskItemView(item: .init(id: "123", title: "Get Milk!", dueDate: Date().timeIntervalSince1970, createDate: Date().timeIntervalSince1970, isDone: false))
    }
}
