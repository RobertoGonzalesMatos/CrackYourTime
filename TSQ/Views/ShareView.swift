//
//  NewItemView.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/30/23.
//

import SwiftUI

struct ShareView: View {
    @ObservedObject var viewModel: ShareViewModel
    @State var name: String = ""
//    @Binding var newItemPresented: Bool
    
    var body: some View {
        VStack{
            Text("Share")
                .bold()
                .font(.system(size: 30))
                .padding(20)
            Form{
                TextField("Name", text: $name)
                    .textFieldStyle(DefaultTextFieldStyle())
                
                
                ButtonView(title:"Save", backroundColor: .blue){

                    viewModel.share(shareName: name)
                }
                .alert(isPresented: $viewModel.alert){
                    Alert(title: Text("Error"), message: Text("Please enter a valid user"))
                }
            }
        }
        .frame(minWidth: 300, maxWidth: 400, minHeight: 100, maxHeight: 300)
    }
}

struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        NewItemSQView(newItemPresented: Binding(get: {return true}, set: {_ in}))
    }
}


