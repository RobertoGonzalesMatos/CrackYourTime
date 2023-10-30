//
//  NewItemView.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/30/23.
//

import SwiftUI

struct NewItemSQView: View {
    @StateObject var  viewModel = NewSQViewModel()
    @Binding var newItemPresented: Bool
    
    var body: some View {
        VStack{
            Text("New Item")
                .bold()
                .font(.system(size: 30))
                .padding(20)
            Form{
                TextField("Title", text: $viewModel.title)
                    .textFieldStyle(DefaultTextFieldStyle())
                
                
                ButtonView(title:"Save", backroundColor: .green){
                    if viewModel.canSave {
                        viewModel.save()
                        newItemPresented = false
                    } else {
                        viewModel.showAlert = true
                    }
                }
                .alert(isPresented: $viewModel.showAlert){
                    Alert(title: Text("Error"), message: Text("Please Fill All Fields and Select Valid Due Date"))
                }
            }
        }
        .frame(minWidth: 300, maxWidth: 400, minHeight: 100, maxHeight: 300)
    }
}

struct NewItemSQView_Previews: PreviewProvider {
    static var previews: some View {
        NewItemSQView(newItemPresented: Binding(get: {return true}, set: {_ in}))
    }
}

