//
//  BlockBlastModel.swift
//  BlockBlast
//
//  Created by Aadharsh Rajkumar on 12/15/25.
//

import Foundation
import SwiftUI

struct GridCell: Identifiable, Equatable {
    let id = UUID()
    var isFilled: Bool
    var color: Color?
    
    static let empty = GridCell(isFilled: false, color: nil)
    
    init(isFilled: Bool = false, color: Color? = nil) {
        self.isFilled = isFilled
        self.color = color
    }
}

struct BlockPiece: Identifiable, Equatable {
    let id = UUID()
    let shape: [[Bool]]
    let color: Color
    var isUsed: Bool = false
    
    var width: Int { shape[0].count }
    var height: Int { shape.count }
    
    var filledCells: [(row: Int, col: Int)] {
        var cells: [(row: Int, col: Int)] = []
        for row in 0..<shape.count {
            for col in 0..<shape[row].count {
                if shape[row][col] {
                    cells.append((row, col))
                }
            }
        }
        return cells
    }
    
    static func == (lhs: BlockPiece, rhs: BlockPiece) -> Bool {
        lhs.id == rhs.id
    }
}

struct PieceTemplates {
    static func randomPiece() -> BlockPiece {
        let templates = allTemplates
        let template = templates.randomElement()!
        let color = BlockBlastConstants.blockColors.randomElement()!
        return BlockPiece(shape: template, color: color)
    }
    
    static let allTemplates: [[[Bool]]] = [
        // 1x1 - Single block
        [[true]],
        
        // 1x2 - Horizontal pair
        [[true, true]],
        
        // 2x1 - Vertical pair
        [[true], [true]],
        
        // 1x3 - Horizontal triple
        [[true, true, true]],
        
        // 3x1 - Vertical triple
        [[true], [true], [true]],
        
        // 2x2 - Square
        [[true, true], [true, true]],
        
        // L-shape (4 rotations)
        [[true, false], [true, false], [true, true]],
        [[true, true, true], [true, false, false]],
        [[true, true], [false, true], [false, true]],
        [[false, false, true], [true, true, true]],
        
        // Reverse L-shape
        [[false, true], [false, true], [true, true]],
        [[true, false, false], [true, true, true]],
        [[true, true], [true, false], [true, false]],
        [[true, true, true], [false, false, true]],
        
        // T-shape (4 rotations)
        [[true, true, true], [false, true, false]],
        [[true, false], [true, true], [true, false]],
        [[false, true, false], [true, true, true]],
        [[false, true], [true, true], [false, true]],
        
        // 1x4 - Long horizontal
        [[true, true, true, true]],
        
        // 4x1 - Long vertical
        [[true], [true], [true], [true]],
        
        // 3x3 - Large square
        [[true, true, true], [true, true, true], [true, true, true]],
        
        // S-shape
        [[false, true, true], [true, true, false]],
        [[true, false], [true, true], [false, true]],
        
        // Z-shape
        [[true, true, false], [false, true, true]],
        [[false, true], [true, true], [true, false]],
        
        // 1x5 - Very long horizontal
        [[true, true, true, true, true]],
        
        // 5x1 - Very long vertical
        [[true], [true], [true], [true], [true]],
    ]
    
    static let smallTemplates: [[[Bool]]] = [
        [[true]],
        [[true, true]],
        [[true], [true]],
        [[true, true, true]],
        [[true], [true], [true]],
    ]
    
    static func randomSmallPiece() -> BlockPiece {
        let template = smallTemplates.randomElement()!
        let color = BlockBlastConstants.blockColors.randomElement()!
        return BlockPiece(shape: template, color: color)
    }
}

struct GameGrid {
    var cells: [[GridCell]]
    let size: Int
    
    init(size: Int = BlockBlastConstants.gridSize) {
        self.size = size
        self.cells = Array(
            repeating: Array(repeating: GridCell.empty, count: size),
            count: size
        )
    }
    
    func canPlace(piece: BlockPiece, at row: Int, col: Int) -> Bool {
        for cell in piece.filledCells {
            let targetRow = row + cell.row
            let targetCol = col + cell.col
            
            if targetRow < 0 || targetRow >= size || targetCol < 0 || targetCol >= size {
                return false
            }
            
            if cells[targetRow][targetCol].isFilled {
                return false
            }
        }
        return true
    }
    
    mutating func place(piece: BlockPiece, at row: Int, col: Int) {
        for cell in piece.filledCells {
            let targetRow = row + cell.row
            let targetCol = col + cell.col
            cells[targetRow][targetCol] = GridCell(isFilled: true, color: piece.color)
        }
    }
    
    func findCompleteLines() -> (rows: [Int], cols: [Int]) {
        var completeRows: [Int] = []
        var completeCols: [Int] = []
        
        for row in 0..<size {
            if cells[row].allSatisfy({ $0.isFilled }) {
                completeRows.append(row)
            }
        }

        for col in 0..<size {
            var isComplete = true
            for row in 0..<size {
                if !cells[row][col].isFilled {
                    isComplete = false
                    break
                }
            }
            if isComplete {
                completeCols.append(col)
            }
        }
        
        return (completeRows, completeCols)
    }
    
    mutating func clearLines(rows: [Int], cols: [Int]) -> Int {
        var clearedCells = Set<String>()
        
        for row in rows {
            for col in 0..<size {
                clearedCells.insert("\(row),\(col)")
            }
        }
        
        for col in cols {
            for row in 0..<size {
                clearedCells.insert("\(row),\(col)")
            }
        }
        
        for cellKey in clearedCells {
            let parts = cellKey.split(separator: ",")
            let row = Int(parts[0])!
            let col = Int(parts[1])!
            cells[row][col] = GridCell.empty
        }
        
        return clearedCells.count
    }
    
    func canPlaceAnyPiece(_ pieces: [BlockPiece]) -> Bool {
        for piece in pieces {
            if piece.isUsed { continue }
            for row in 0..<size {
                for col in 0..<size {
                    if canPlace(piece: piece, at: row, col: col) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    mutating func reset() {
        cells = Array(
            repeating: Array(repeating: GridCell.empty, count: size),
            count: size
        )
    }
}
