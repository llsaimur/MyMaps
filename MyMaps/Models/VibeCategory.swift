//
//  VibeCategory.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/28/26.
//


import SwiftUI


enum VibeCategory: String, Codable, CaseIterable {
    case LIVELY
    case CHILL
    case LOWKEY
    case BUSINESS
    
    var color: Color {
        switch self {
        case .LIVELY: return .orange
        case .CHILL: return .blue
        case .LOWKEY: return .secondary
        case .BUSINESS: return .black
        }
    }
    
    var icon: String {
        switch self {
        case .LIVELY: return "flame.fill"
        case .CHILL: return "leaf.fill"
        case .LOWKEY: return "eye.slash.fill"
        case .BUSINESS: return "briefcase.fill"
        }
    }
    
    var displayName: String {
        self.rawValue.capitalized
    }
}
