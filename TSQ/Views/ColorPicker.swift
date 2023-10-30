//
//  ColorPicker.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/9/23.
//

import SwiftUI

struct ColorPicker: View {
    let colors:[Color] = [.red, .orange, .green, .blue, .purple, .black, .white]
    @Binding var selectedColor: Color
    @State var eraser: String = "eraser"
    
    var body: some View {
        HStack{
            ForEach(colors, id: \.self) { color in
                if color != Color.white{
                    Image(systemName: selectedColor == color ? "record.circle.fill" : "circle.fill")
                        .foregroundColor(color)
                        .font(.system(size:16))
                        .clipShape(Circle())
                        .onTapGesture {
                            selectedColor = color
                            eraser = "eraser"
                        }
                } else {
                    Image(systemName: eraser)
                        .foregroundColor(.blue)
                        .font(.system(size:16))
                        .onTapGesture {
                            selectedColor = color
                            eraser = "eraser.fill"
                        }
                }
            }
        }
    }
}

struct ColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        ColorPicker(selectedColor: .constant(.blue))
    }
}
