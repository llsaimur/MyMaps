//
//  RegistrationView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//


import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            AuthHeaderView(title: "Get started.", subtitle: "Create your account")
            
            VStack(spacing: 32) {
                CustomInputField(placeholder: "Email", text: $email)
                CustomInputField(placeholder: "Username", text: $username)
                CustomInputField(placeholder: "Password", isSecureField: true, text: $password)
            }
            .padding(.horizontal, 32)
            .padding(.top, 44)
            
            AuthButton(
                title: "Sign Up",
                isDisabled: email.isEmpty || username.isEmpty || password.isEmpty
            ) {
                viewModel.register(withEmail: email, password: password, username: username)
            }
            .padding(.horizontal, 32) // THIS fixes the length
            .padding(.top, 24)        // Gives it breathing room from the fields
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Text("Already have an account?").foregroundColor(.secondary)
                    Text("Sign In").fontWeight(.bold)
                }
                .font(.footnote)
            }
            .padding(.bottom, 32)
        }
        .ignoresSafeArea()
    }
}
