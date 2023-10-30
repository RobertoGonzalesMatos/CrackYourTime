//
//  ProfileView.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/30/23.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView{
            VStack{
                if let user = viewModel.user {
                    profile(user:user)
                } else {
                    Text ("Loading Profile ...")
                }
            }
            .navigationTitle("Profile")
        }
        .onAppear{
            viewModel.fetchUser()
        }
    }
    
    @ViewBuilder
    func profile(user: User) -> some View{
        Image(systemName: "person.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.blue)
            .frame(width: 125,height: 125)
            .padding()
        
        VStack(alignment: .center){
                Text(user.name)
                    .bold()
                Text(user.email)
                    .font(.system(size: 16))
            List{
                Button("Reset PassWord") {
                    
                }
                .listRowBackground(Color.gray)
                Button("Your Data") {
                    
                }
                .listRowBackground(Color.gray)
                Button("Images") {
                    
                }
                .listRowBackground(Color.gray)
                Button("Friends") {
                    
                }
                .listRowBackground(Color.gray)
                .cornerRadius(15)
            }
            .listStyle(PlainListStyle())
            .cornerRadius(7)
            .frame(height: 175)
//            .background(Color.black)
            Spacer()
        }
        ButtonView(title: "Log Out", backroundColor: .red) {
            viewModel.logout()
        }
        .frame(width: 350,height: 70)
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
