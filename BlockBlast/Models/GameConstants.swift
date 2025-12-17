//
//  GameConstants.swift
//  BlockBlast
//
//  Created by Aadharsh Rajkumar on 12/15/25.
//

import Foundation
import UIKit
import SwiftUI

struct BlockBlastConstants {
    static var screenHeight: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return 844
        }
        return window.bounds.height
    }
    
    static var screenWidth: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return 390
        }
        return window.bounds.width
    }
    
    static let gridSize: Int = 8
    static var gridCellSize: CGFloat {
        let availableWidth = screenWidth * 0.85
        return (availableWidth - CGFloat(gridSize + 1) * cellSpacing) / CGFloat(gridSize)
    }
    static var cellSpacing: CGFloat { 3 }
    static var cellCornerRadius: CGFloat { gridCellSize * 0.15 }
    
    static let piecesPerRound: Int = 3
    static var trayCellSize: CGFloat { 18 }
    static var trayCellSpacing: CGFloat { 2 }
    static var traySlotSize: CGFloat { 100 }
    
    static var smartFitRadius: CGFloat { screenWidth * 0.4 }
    
    static let pointsPerBlock: Int = 1
    static let lineClearBonus: Int = 10
    static func comboMultiplier(for comboCount: Int) -> Int {
        return comboCount * (comboCount + 1) / 2
    }
    
    static let cravrGreen = Color(hex: "1CD91F")      // Bright green
    static let cravrBlue = Color(hex: "92DCE5")       // Light blue
    static let cravrMaize = Color(hex: "F7EC59")      // Yellow
    static let cravrPumpkin = Color(hex: "FA7921")    // Orange
    
    static let cravrDarkBackground = Color(red: 0.05, green: 0.12, blue: 0.08) // Dark green tint
    static let cravrDarkSurface = Color(red: 0.08, green: 0.15, blue: 0.10)    // Slightly lighter
    
    static let gridBackground = Color(red: 0.06, green: 0.14, blue: 0.09).opacity(0.9)
    static let emptyCell = Color(red: 0.08, green: 0.18, blue: 0.11)
    
    static let blockColors: [Color] = [
        cravrGreen,     // Green blocks
        cravrBlue,      // Blue blocks
        cravrMaize,     // Yellow blocks
        cravrPumpkin,   // Orange blocks
    ]
    
    static let glowRadius: CGFloat = 12
    static let glowOpacity: Double = 0.6
    
    static let placementAnimationDuration: Double = 0.15
    static let clearAnimationDuration: Double = 0.25
    static let comboOverlayDuration: Double = 0.8
    static let menuTransitionDuration: Double = 0.3
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: 
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
