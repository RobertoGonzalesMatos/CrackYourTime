//
//  ContentView.swift
//  TSQ
//
//  Created by Roberto Gonzales on 8/4/23.
//

import SwiftUI
import FortuneWheel

struct ContentView: View {
    @State var selectedIndex: Int = 0
    @State private var showMessage = false
    var players = ["Sameer", "Spikey", "Amelia", "Joan", "Karen", "Natalie"]
    var body: some View {
        ZStack {
            FortuneWheel(titles: players, size: 320, onSpinEnd: { index in
                // your action here - based on index
                selectedIndex = index
                showMessage = true
            })
        }
        .alert(isPresented: $showMessage) {
                            Alert(
                                title: Text("\(players[selectedIndex])"),
                                message: Text("\("")"),
                                dismissButton: .default(Text("OK"))
                            )
                        }
        
        }
    }


struct contentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
