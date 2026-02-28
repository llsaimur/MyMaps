//
//  UserStatView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/28/26.
//

import SwiftUI

struct UserStatView: View {
    let value: Int
    let label: String
    var body: some View {
        VStack {
            Text("\(value)").font(.subheadline).bold()
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}
