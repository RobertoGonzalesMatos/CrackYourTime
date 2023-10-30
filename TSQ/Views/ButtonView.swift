//
//  ButtonView.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/31/23.
//

import SwiftUI

struct ButtonView: View {
    let title: String
    let backroundColor: Color
    let action: ()-> Void
    
    
    var body: some View {
        Button{
            action()
        } label: {
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(backroundColor)
                Text(title)
                    .foregroundColor(Color.white)
                    .bold()
            }
        }
        .padding()
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(title:"value",backroundColor: Color.blue){
            //action
        }
    }
}
