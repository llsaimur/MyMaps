//
//  VibeType.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/1/26.
//

import SwiftUI

enum VibeType: String, Codable, CaseIterable {
    case ROMANTIC, CHILL, LOWKEY, BUSINESS
    
    var color: Color {
        switch self {
        case .ROMANTIC: return .pink
        case .CHILL: return .blue
        case .LOWKEY: return .secondary
        case .BUSINESS: return .black
        }
    }
    
    var icon: String {
        switch self {
        case .ROMANTIC: return "heart.fill"
        case .CHILL: return "leaf.fill"
        case .LOWKEY: return "eye.slash.fill"
        case .BUSINESS: return "briefcase.fill"
        }
    }
}
