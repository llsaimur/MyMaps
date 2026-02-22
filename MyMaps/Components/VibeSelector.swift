//
//  VibeSelector.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/16/26.
//

import SwiftUI

struct VibeSelector: View {
    @Binding var selectedVibe: VibeType
    var label: String = "Vibe Check"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label).font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(VibeType.allCases, id: \.self) { vibe in
                        VibeChip(vibe: vibe, isSelected: selectedVibe == vibe) {
                            HapticManager.trigger(.light)
                            selectedVibe = vibe
                        }
                    }
                }
            }
        }
    }
}
