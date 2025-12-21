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
    
    @Published var soundEnabled: Bool = true
    @Published var hapticsEnabled: Bool = true
    
    @Published var clearingRows: Set<Int> = []
    @Published var clearingCols: Set<Int> = []
    @Published var lastPlacedCells: [(row: Int, col: Int)] = []

    @Published var showComboOverlay: Bool = false
    @Published var comboText: String = ""
    @Published var linesCleared: Int = 0
    
    @Published var draggedPieceIndex: Int? = nil
    @Published var dragOffset: CGSize = .zero
    @Published var previewPosition: (row: Int, col: Int)? = nil
    @Published var isValidPlacement: Bool = false
    
    private let haptics = BlockBlast_Haptics.shared
    
    init() {
        loadHighScore()
        loadSettings()
    }
    
    func startGame() {
        guard gameState != .playing else { return }
        
        gameState = .playing
        grid.reset()
        score = 0
        hasPlayedOnce = true
        
        generateSmartPieces()
        
        if hapticsEnabled {
            haptics.gameStartHaptic()
        }
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
        showComboOverlay = false
    }
    
    func exitToMenu() {
        if score > highScore {
            highScore = score
            saveHighScore()
        }
        resetGame()
    }
    
    func toggleSound() {
        soundEnabled.toggle()
        saveSettings()
    }
    
    func toggleHaptics() {
        hapticsEnabled.toggle()
        saveSettings()
    }
    
    private func loadSettings() {
        soundEnabled = UserDefaults.standard.object(forKey: "blockBlastSoundEnabled_v2") as? Bool ?? true
        hapticsEnabled = UserDefaults.standard.object(forKey: "blockBlastHapticsEnabled_v2") as? Bool ?? true
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(soundEnabled, forKey: "blockBlastSoundEnabled_v2")
        UserDefaults.standard.set(hapticsEnabled, forKey: "blockBlastHapticsEnabled_v2")
    }

    private func generateSmartPieces() {
        var attempts = 0
        var pieces: [BlockPiece] = []
        
        repeat {
            pieces = (0..<BlockBlastConstants.piecesPerRound).map { _ in
                PieceTemplates.randomPiece()
            }
            attempts += 1
        } while !grid.canPlaceAnyPiece(pieces) && attempts < 10
        
        if !grid.canPlaceAnyPiece(pieces) {
            pieces = (0..<BlockBlastConstants.piecesPerRound).map { _ in
                PieceTemplates.randomSmallPiece()
            }
        }
        
        availablePieces = pieces
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
        
        let blocksPlaced = piece.filledCells.count
        score += blocksPlaced * BlockBlastConstants.pointsPerBlock

        if hapticsEnabled {
            haptics.impact(.medium)
        }
        
        if soundEnabled {
            BlockBlast_Audio.shared.playPlace()
        }
        
        let (rows, cols) = grid.findCompleteLines()
        
        if !rows.isEmpty || !cols.isEmpty {
            let totalLines = rows.count + cols.count
            linesCleared = totalLines
            
            withAnimation(.easeInOut(duration: BlockBlastConstants.clearAnimationDuration)) {
                clearingRows = Set(rows)
                clearingCols = Set(cols)
            }

            let lineScore = totalLines * BlockBlastConstants.lineClearBonus
            let multiplier = BlockBlastConstants.comboMultiplier(for: totalLines)
            let totalLineScore = lineScore * multiplier
            score += totalLineScore

            if totalLines > 1 {
                showComboOverlay(lines: totalLines, multiplier: multiplier)
            }
            
            if hapticsEnabled {
                haptics.lineClearHaptic(lineCount: totalLines)
            }
            
            if soundEnabled {
                BlockBlast_Audio.shared.playClear()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + BlockBlastConstants.clearAnimationDuration) {
                _ = self.grid.clearLines(rows: rows, cols: cols)
                self.clearingRows = []
                self.clearingCols = []
            }
        }
        
        if allPiecesUsed() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.generateSmartPieces()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + BlockBlastConstants.clearAnimationDuration + 0.1) {
            if !self.grid.canPlaceAnyPiece(self.availablePieces) {
                self.gameOver()
            }
        }
        
        resetDragState()
    }
    
    private func showComboOverlay(lines: Int, multiplier: Int) {
        comboText = getComboText(for: lines)
        showComboOverlay = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + BlockBlastConstants.comboOverlayDuration) {
            self.showComboOverlay = false
        }
    }
    
    private func getComboText(for lines: Int) -> String {
        switch lines {
        case 2: return "DOUBLE!"
        case 3: return "TRIPLE!"
        case 4: return "QUAD!"
        case 5: return "PENTA!"
        default: return "COMBO x\(lines)!"
        }
    }
    
    func findBestPlacement(for pieceIndex: Int, near point: CGPoint, gridFrame: CGRect) -> (row: Int, col: Int)? {
        guard pieceIndex < availablePieces.count else { return nil }
        let piece = availablePieces[pieceIndex]

        let strictGridFrame = gridFrame.insetBy(dx: -10, dy: -10)
        
        if !strictGridFrame.contains(point) {
            return nil
        }

        let padding = BlockBlastConstants.cellSpacing * 2
        let cellWithSpacing = BlockBlastConstants.gridCellSize + BlockBlastConstants.cellSpacing
        
        let relativeX = point.x - gridFrame.minX
        let relativeY = point.y - gridFrame.minY
        
        let centerCol = Int((relativeX - padding) / cellWithSpacing)
        let centerRow = Int((relativeY - padding) / cellWithSpacing)
        
        for radius in 0...BlockBlastConstants.gridSize {
            for rowOffset in -radius...radius {
                for colOffset in -radius...radius {
                    if abs(rowOffset) != radius && abs(colOffset) != radius { continue }
                    
                    let testRow = centerRow + rowOffset
                    let testCol = centerCol + colOffset

                    guard testRow >= 0 && testCol >= 0 else { continue }
                    guard testRow < BlockBlastConstants.gridSize && testCol < BlockBlastConstants.gridSize else { continue }
                    
                    if grid.canPlace(piece: piece, at: testRow, col: testCol) {
                        return (testRow, testCol)
                    }
                }
            }
        }
        
        return nil
    }
    
    func startDrag(pieceIndex: Int) {
        draggedPieceIndex = pieceIndex
        if hapticsEnabled {
            haptics.impact(.light)
        }
        
        if soundEnabled {
            BlockBlast_Audio.shared.playPickup()
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
            
            if isValid && hapticsEnabled {
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
        if hapticsEnabled {
            haptics.gameOverHaptic()
        }
        
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
