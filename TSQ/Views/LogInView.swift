//
//  LogInView.swift
//  TSQ
//
//  Created by Roberto Gonzales on 7/30/23.
//

import SwiftUI

struct LogInView: View {
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationView{
            VStack{
                HeaderView(title: "Tasks & SideQuests", angle: 15, backroundColor: Color.green)
                //Login Form
                
                Form {
                    if !viewModel.errorMessage.isEmpty{
                        Text(viewModel.errorMessage).foregroundColor(Color.red)
                    }
                    
                    TextField("Email Address", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    ButtonView(title: "Log In", backroundColor: .blue){
                        viewModel.logIn()
                    }
                }
                .offset(y:-50)
                .frame(minWidth: 300, maxWidth: 400, minHeight: 300, maxHeight: 400)
                //Create Account
                VStack{
                    Text("New arround here?")
                    NavigationLink("Create New Account",
                                   destination: RegisterView())
                }
                .padding(15)
                
                Spacer()
            }
        }
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
