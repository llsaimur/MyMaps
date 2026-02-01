//
//  CustomInputField.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//

import SwiftUI

import SwiftUI

struct CustomInputField: View {
    let placeholder: String
    var isSecureField: Bool = false
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Group {
                if isSecureField {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(placeholder == "Email" ? .emailAddress : .default)
                }
            }
            .font(.subheadline)
            .padding(.leading, 4)
            
            Divider()
                .background(Color(.systemGray4))
        }
    }
}
