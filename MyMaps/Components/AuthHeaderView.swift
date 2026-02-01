//
//  AuthHeaderView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 1/31/26.
//

import SwiftUI

struct AuthHeaderView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack { Spacer() }
            Text(title).font(.largeTitle).fontWeight(.semibold)
            Text(subtitle).font(.title2).fontWeight(.semibold)
        }
        .padding(.top, 96)
        .padding(.leading)
        .padding(.bottom, 44)
        .background(Color.blue)
        .foregroundColor(.white)
        .clipShape(RoundedShape(corners: [.bottomRight]))
    }
}
