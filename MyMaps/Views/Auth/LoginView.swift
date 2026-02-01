//
//  LoginView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//


import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                AuthHeaderView(title: "Hello.", subtitle: "Welcome Back")
                
                VStack(spacing: 32) {
                    CustomInputField(placeholder: "Email", text: $email)
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        CustomInputField(placeholder: "Password", isSecureField: true, text: $password)
                        
                        NavigationLink("Forgot Password?") {
                            Text("Reset Password View")
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 44)
                
                if let error = viewModel.errorMessage {
                    FormErrorView(message: error)
                        .padding(.top)
                }
                
                AuthButton(
                    title: "Sign In",
                    isDisabled: email.isEmpty || password.isEmpty
                ) {
                    viewModel.login(withEmail: email, password: password)
                }
                .padding(.horizontal, 32) // THIS fixes the length
                .padding(.top, 24)        // Gives it breathing room from the fields
                
                Spacer()
                
                NavigationLink {
                    RegistrationView().navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 4) {
                        Text("Don't have an account?").foregroundColor(.secondary)
                        Text("Sign Up").fontWeight(.bold)
                    }
                    .font(.footnote)
                }
                .padding(.bottom, 32)
            }
            .ignoresSafeArea()
        }
    }
}
