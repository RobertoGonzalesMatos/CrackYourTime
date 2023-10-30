//
//  DrawView.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/9/23.
//

import SwiftUI
import UIKit

struct DrawView: View {
    @State private var currentLine = Line()
    @State private var lines: [Line] = []
    @State private var selectedColor: Color = .black
    @State private var thickness: Double = 1.0
    @State var uId: String = ""

    init(id: String){
        self.uId = id
    }
    
    var canvas: some View{
        Canvas{ context, size in
            for line in lines{
                var path = Path()
                path.addLines(line.points)
                context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
            }
            
        }
    }
    
    var body: some View {
        VStack{
            Capsule().frame(width: 200, height: 10).foregroundColor(.black.opacity(0.7))
            Divider()
            canvas
            .frame(width: 400,height: 450)
            .gesture(DragGesture(minimumDistance: 0,coordinateSpace: .local)
                .onChanged({value in
                    let newPoint = value.location
                    currentLine.points.append(newPoint)
                    self.lines.append(currentLine)
            })
            .onEnded({value in
                self.lines.removeLast(currentLine.points.count)
                self.lines.append(currentLine)
//                print(lines.count)
                self.currentLine = Line(points:[], color: selectedColor, lineWidth: thickness)
            })
            )
            Divider()
            VStack {
                Slider(value:$thickness, in: 1...40) {
                    Text("Thickness")
                }.frame(maxWidth: 250)
                    .onChange(of: thickness) { newValue in
                        currentLine.lineWidth = newValue
                    }
                HStack {
                    ColorPicker(selectedColor: $selectedColor).onChange(of: selectedColor){
                        newColor in currentLine.color = newColor
                    }
                }
                ButtonView(title:"Save", backroundColor: .blue){
//                    if let view = canvas as? Canvas<EmptyView> {
                        let view = canvas.frame(width: 400,height: 450)
                        let image = view.snapshot()
                        let drawViewModel = DrawViewModel()
                        drawViewModel.save(image: image, uId: uId)
//                    }
//                    print(lines.count)
//                    let drawViewModel = DrawViewModel()
//                    drawViewModel.drawing = lines
//                    drawViewModel.save()
                }
                .frame(width: 350,height: 70)
            }
        }
    }
}

struct DrawView_Previews: PreviewProvider {
    static var previews: some View {
        DrawView(id: "ZQhOQS6ofvfq7rY0SnX1dhFn9qx1")
    }
}
