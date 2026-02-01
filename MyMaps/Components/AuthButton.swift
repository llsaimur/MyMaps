//
//  AuthButton.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//

import SwiftUI

struct AuthButton: View {
    let title: String
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isDisabled ? Color(.systemGray4) : Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .disabled(isDisabled)
    }
}
