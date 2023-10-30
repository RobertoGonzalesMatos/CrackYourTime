//
//  ContentView.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/30/23.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()

    var body: some View {
        if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
            // Signed-in View
            accountView
            
        } else {
            LogInView()
        }
    }

    @ViewBuilder
    var accountView: some View {
        TabView() {
            NewTaskView(userId: viewModel.currentUserId)
                .tabItem {
                    Label("Tasks", systemImage: "house")
                }

            SQView(userId: viewModel.currentUserId)
                .tabItem {
                    Label("SideQuests", systemImage: "leaf")
                }

            RandomView(userId: viewModel.currentUserId)
                .tabItem {
                    Label("Random", systemImage: "sparkles")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
