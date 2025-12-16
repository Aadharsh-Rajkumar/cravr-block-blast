//
//  BlockBlast_Haptics.swift
//  BlockBlast
//
//  Created by Aadharsh Rajkumar on 12/15/25.
//

import UIKit
import CoreHaptics

final class BlockBlast_Haptics {
    static let shared = BlockBlast_Haptics()
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    private var hapticEngine: CHHapticEngine?
    
    private init() {
        prepareAll()
        setupCoreHaptics()
    }
    
    func prepareAll() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        selection.prepare()
        notification.prepare()
    }
    
    private func setupCoreHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
        }
    }
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light:
            lightImpact.impactOccurred()
        case .medium:
            mediumImpact.impactOccurred()
        case .heavy:
            heavyImpact.impactOccurred()
        case .soft:
            lightImpact.impactOccurred()
        case .rigid:
            heavyImpact.impactOccurred()
        @unknown default:
            mediumImpact.impactOccurred()
        }
    }
    
    func selectionHaptic() {
        selection.selectionChanged()
    }
    
    func gameStartHaptic() {
        notification.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            self.impact(.light)
        }
    }
    
    func pickupHaptic() {
        impact(.light)
    }
    
    func placementHaptic() {
        impact(.medium)
    }
    
    func lineClearHaptic(lineCount: Int) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            notification.notificationOccurred(.success)
            return
        }
        
        let intensity = min(1.0, 0.5 + (Float(lineCount) * 0.15))
        let sharpness: Float = 0.8
        
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        
        var events: [CHHapticEvent] = []
        
        for i in 0..<lineCount {
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensityParam, sharpnessParam],
                relativeTime: Double(i) * 0.08
            )
            events.append(event)
        }
        
        let finalEvent = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: Double(lineCount) * 0.08 + 0.05
        )
        events.append(finalEvent)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            notification.notificationOccurred(.success)
        }
    }
    
    func comboClearHaptic(comboCount: Int) {
        for i in 0..<comboCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                self.impact(.heavy)
            }
        }
    }

    func gameOverHaptic() {
        notification.notificationOccurred(.error)
    }

    func invalidPlacementHaptic() {
        notification.notificationOccurred(.warning)
    }
}
