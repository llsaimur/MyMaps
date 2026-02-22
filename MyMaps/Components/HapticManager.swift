//
//  HapticManager.swift
//  MyMaps
//
//  Created by Saimur Rashid on 2/16/26.
//


import UIKit

enum HapticManager {
    static func trigger(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func trigger(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}