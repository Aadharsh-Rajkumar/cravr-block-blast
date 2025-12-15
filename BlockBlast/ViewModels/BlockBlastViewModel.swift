//
//  BlockBlastViewModel.swift
//  BlockBlast
//
//  Created by Aadharsh Rajkumar on 12/15/25.
//


import Foundation
import SwiftUI
import Combine

final class BlockBlastViewModel: ObservableObject {

    enum GameState {
        case menu
        case playing
        case gameOver
    }

    @Published var gameState: GameState = .menu

    @Published var score: Int = 0

    func startGame() {
        gameState = .playing
        score = 0
    }

    func endGame() {
        gameState = .gameOver
    }

    func resetGame() {
        gameState = .menu
        score = 0
    }
}
