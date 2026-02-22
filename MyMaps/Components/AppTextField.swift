//
//  AppTextField.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/16/26.
//

import SwiftUI

struct AppTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.headline)
            TextField(placeholder, text: $text, axis: .vertical)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .lineLimit(3...5)
        }
    }
}
