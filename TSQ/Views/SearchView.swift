//
//  SearchView.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/22/23.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var GPTViewModel = ChatGPTViewModel()
    @Binding var title: String
    @State var response: String = ""
    
    var body: some View {
        VStack{
            Text("Regarding " + title + ":")
                .padding()
                .font(.title)
                .bold()
            if response == "" {
                ProgressView()
                    .tint(.black)
            } else {
                Text(response)
                    .padding()
                    .offset(y:-50)
            }
        }
        .onAppear(){
            GPTViewModel.setUpdirect()
            GPTViewModel.search(text: title) { a in
                response = a
                print(response)
            }
        }
        .frame(minWidth: 300, maxWidth: 400, minHeight: 150, maxHeight: 400)
    }
}

//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchView(title: .constant("podcast"))
//    }
//}
