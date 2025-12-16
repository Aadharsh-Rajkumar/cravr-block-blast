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
    static var cellSize: CGFloat {
        let availableWidth = screenWidth * 0.9
        return availableWidth / CGFloat(gridSize)
    }
    static var cellSpacing: CGFloat { cellSize * 0.08 }
    static var cellCornerRadius: CGFloat { cellSize * 0.15 }
    
    static var snapThreshold: CGFloat { cellSize * 0.6 }
    
    static let piecesPerRound: Int = 3
    static var piecePreviewScale: CGFloat { 0.6 }
    static var pieceDragScale: CGFloat { 0.8 }
    
    static let pointsPerBlock: Int = 10
    static let lineBonus: Int = 50
    static let comboMultiplier: Int = 2
    
    static let primaryGreen = Color(hex: "1a4d2e")
    static let secondaryGreen = Color(hex: "2d6a4f")
    static let accentLime = Color(hex: "95d524")
    static let accentYellow = Color(hex: "d4f542")
    static let deepGreen = Color(hex: "0d2818")
    static let gridBackground = Color(hex: "1e5631")
    static let emptyCell = Color(hex: "143d29")
    
    static let maize = accentYellow
    static let pumpkin = accentLime
    static let nonPhotoBlue = Color(hex: "92dce5")
    
    static let blockColors: [Color] = [
        Color(hex: "95d524"),
        Color(hex: "d4f542"),
        Color(hex: "ff6b6b"),
        Color(hex: "4ecdc4"),
        Color(hex: "ffe66d"),
        Color(hex: "ff8c42"),
    ]

    static let placementAnimationDuration: Double = 0.15
    static let clearAnimationDuration: Double = 0.3
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
