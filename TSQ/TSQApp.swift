//
//  TSQApp.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/30/23.
//
import FirebaseCore
import SwiftUI

@main
struct TSQApp: App {
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
