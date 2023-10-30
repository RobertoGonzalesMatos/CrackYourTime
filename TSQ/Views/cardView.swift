//
//  cardView.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/11/23.
//

import SwiftUI

struct cardView: View {
    @State var rotation: CGFloat = 0.0
    @State var text: String
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(width: 260,height: 340)
                .foregroundColor(Color(UIColor(named: "darkBlue")!).opacity(0.8))
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(width: 130,height: 500)
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color(UIColor(named: "lightBlue")!),Color(UIColor(named: "magenta")!)]), startPoint: .top, endPoint: .bottom))
                .rotationEffect(.degrees(rotation))
                .mask(RoundedRectangle(cornerRadius: 20,style: .continuous).stroke(lineWidth: 7).frame(width: 256,height: 336))
            Text(text)
                .font(.title)
                .bold()
                .foregroundColor(.white)
                .frame(width: 245,height: 330)
                .multilineTextAlignment(.center)
        }
        .onAppear(){
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)){
                rotation = 360
            }
        }
    }
}

struct cardView_Previews: PreviewProvider {
    static var previews: some View {
        cardView(text: "CARD")
    }
}
