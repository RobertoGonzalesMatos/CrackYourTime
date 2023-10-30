//
//  HeaderView.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/30/23.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    let angle: Double
    let backroundColor: Color
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(backroundColor)
                .rotationEffect(Angle(degrees: angle))

            VStack{
                Text(title)
                    .font(.system(size: 50))
                    .foregroundColor(Color.white)
                    .bold()
                    .multilineTextAlignment(.center)
                    .frame(width: 300)
            }
            .padding(.top,80)
        }
        .offset(y:-150)
        .frame(width: UIScreen.main.bounds.width*3, height: 350)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(title: "Tasks & SideQuests", angle: 15, backroundColor: Color.green)
    }
}
