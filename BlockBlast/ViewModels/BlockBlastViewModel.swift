//
//  BlockBlastViewModel.swift
//  BlockBlast
//
//  Created by Aadharsh Rajkumar on 12/15/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class BlockBlastViewModel: ObservableObject {
    @Published var gameState: BlockBlastGameState = .menu
    @Published var grid: GameGrid = GameGrid()
    @Published var availablePieces: [BlockPiece] = []
    @Published var score: Int = 0
    @Published var highScore: Int = 0
    @Published var hasPlayedOnce: Bool = false
    
    @Published var clearingRows: Set<Int> = []
    @Published var clearingCols: Set<Int> = []
    @Published var lastPlacedCells: [(row: Int, col: Int)] = []
    
    @Published var draggedPieceIndex: Int? = nil
    @Published var dragOffset: CGSize = .zero
    @Published var previewPosition: (row: Int, col: Int)? = nil
    @Published var isValidPlacement: Bool = false
    
    private let haptics = BlockBlast_Haptics.shared

    init() {
        loadHighScore()
    }
    
    func startGame() {
        guard gameState != .playing else { return }
        
        gameState = .playing
        grid.reset()
        score = 0
        hasPlayedOnce = true
        
        generateNewPieces()
        
        haptics.gameStartHaptic()
    }
    
    func resetGame() {
        if score > highScore {
            highScore = score
            saveHighScore()
        }
        
        gameState = .menu
        grid.reset()
        score = 0
        availablePieces = []
        clearingRows = []
        clearingCols = []
    }

    private func generateNewPieces() {
        availablePieces = (0..<BlockBlastConstants.piecesPerRound).map { _ in
            PieceTemplates.randomPiece()
        }
    }
    
    private func allPiecesUsed() -> Bool {
        availablePieces.allSatisfy { $0.isUsed }
    }
    
    func placePiece(at pieceIndex: Int, gridRow: Int, gridCol: Int) {
        guard pieceIndex < availablePieces.count else { return }
        let piece = availablePieces[pieceIndex]
        
        guard grid.canPlace(piece: piece, at: gridRow, col: gridCol) else { return }
        
        grid.place(piece: piece, at: gridRow, col: gridCol)
        availablePieces[pieceIndex].isUsed = true
        
        lastPlacedCells = piece.filledCells.map { (gridRow + $0.row, gridCol + $0.col) }
        
        haptics.impact(.medium)
        
        let (rows, cols) = grid.findCompleteLines()
        
        if !rows.isEmpty || !cols.isEmpty {
            withAnimation(.easeInOut(duration: BlockBlastConstants.clearAnimationDuration)) {
                clearingRows = Set(rows)
                clearingCols = Set(cols)
            }
            
            let linesCleared = rows.count + cols.count
            let clearedCells = grid.clearLines(rows: rows, cols: cols)
            
            let lineScore = clearedCells * BlockBlastConstants.pointsPerBlock
            let bonus = linesCleared * BlockBlastConstants.lineBonus
            let comboBonus = linesCleared > 1 ? (linesCleared - 1) * BlockBlastConstants.lineBonus * BlockBlastConstants.comboMultiplier : 0
            
            score += lineScore + bonus + comboBonus
            
            haptics.lineClearHaptic(lineCount: linesCleared)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + BlockBlastConstants.clearAnimationDuration) {
                self.clearingRows = []
                self.clearingCols = []
            }
        }
        
        if allPiecesUsed() {
            generateNewPieces()
        }
        
        if !grid.canPlaceAnyPiece(availablePieces) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.gameOver()
            }
        }

        resetDragState()
    }
    
    func startDrag(pieceIndex: Int) {
        draggedPieceIndex = pieceIndex
        haptics.impact(.light)
    }
    
    func updateDrag(offset: CGSize, gridFrame: CGRect, cellSize: CGFloat) {
        dragOffset = offset
        
        guard let pieceIndex = draggedPieceIndex,
              pieceIndex < availablePieces.count else {
            previewPosition = nil
            isValidPlacement = false
            return
        }
    }
    
    func updatePreviewPosition(row: Int, col: Int) {
        guard let pieceIndex = draggedPieceIndex,
              pieceIndex < availablePieces.count else {
            previewPosition = nil
            isValidPlacement = false
            return
        }
        
        let piece = availablePieces[pieceIndex]

        let isValid = grid.canPlace(piece: piece, at: row, col: col)

        if previewPosition?.row != row || previewPosition?.col != col {
            previewPosition = (row, col)
            isValidPlacement = isValid
            
            if isValid {
                haptics.selectionHaptic()
            }
        }
    }
    
    func endDrag() {
        guard let pieceIndex = draggedPieceIndex,
              let position = previewPosition,
              isValidPlacement else {
            resetDragState()
            return
        }
        
        placePiece(at: pieceIndex, gridRow: position.row, gridCol: position.col)
    }
    
    func resetDragState() {
        draggedPieceIndex = nil
        dragOffset = .zero
        previewPosition = nil
        isValidPlacement = false
        lastPlacedCells = []
    }
    
    private func gameOver() {
        haptics.gameOverHaptic()
        
        if score > highScore {
            highScore = score
            saveHighScore()
        }
        
        gameState = .gameOver
    }
    
    private func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: "blockBlastHighScore")
    }
    
    private func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: "blockBlastHighScore")
    }
}
