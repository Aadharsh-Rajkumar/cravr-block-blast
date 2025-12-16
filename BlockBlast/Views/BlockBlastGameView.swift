//
//  BlockBlastGameView.swift
//  BlockBlast
//
//  Created by Aadharsh Rajkumar on 12/15/25.
//

import SwiftUI

struct BlockBlastGameView: View {
    @ObservedObject var viewModel: BlockBlastViewModel
    @State private var gridFrame: CGRect = .zero
    
    var body: some View {
        VStack(spacing: 20) {
            ScoreDisplayView(score: viewModel.score)
                .padding(.top, BlockBlastConstants.screenHeight * 0.05)
            
            Spacer()
            
            BlockGridView(
                viewModel: viewModel,
                gridFrame: $gridFrame
            )
            
            Spacer()
            
            PieceTrayView(viewModel: viewModel, gridFrame: gridFrame)
                .padding(.bottom, BlockBlastConstants.screenHeight * 0.05)
        }
    }
}

struct ScoreDisplayView: View {
    let score: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: BlockBlastConstants.screenWidth * 0.0375)
                .frame(width: BlockBlastConstants.screenWidth * 0.5, height: BlockBlastConstants.screenHeight * 0.07)
                .foregroundColor(.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: BlockBlastConstants.screenWidth * 0.0375)
                        .stroke(BlockBlastConstants.accentLime.opacity(0.3), lineWidth: 1)
                )
            
            Text("Score: \(score)")
                .font(.system(size: BlockBlastConstants.screenWidth * 0.055, weight: .bold, design: .rounded))
                .foregroundColor(BlockBlastConstants.accentYellow)
                .shadow(color: .black, radius: 2, x: 1, y: 1)
        }
    }
}

struct BlockGridView: View {
    @ObservedObject var viewModel: BlockBlastViewModel
    @Binding var gridFrame: CGRect
    
    private let gridSize = BlockBlastConstants.gridSize
    private var cellSize: CGFloat {
        let availableWidth = BlockBlastConstants.screenWidth * 0.9
        return (availableWidth - CGFloat(gridSize - 1) * BlockBlastConstants.cellSpacing) / CGFloat(gridSize)
    }
    
    var body: some View {
        VStack(spacing: BlockBlastConstants.cellSpacing) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: BlockBlastConstants.cellSpacing) {
                    ForEach(0..<gridSize, id: \.self) { col in
                        GridCellView(
                            cell: viewModel.grid.cells[row][col],
                            isClearing: viewModel.clearingRows.contains(row) || viewModel.clearingCols.contains(col),
                            isPreview: isPreviewCell(row: row, col: col) && viewModel.isValidPlacement,
                            cellSize: cellSize,
                            previewColor: viewModel.draggedPieceIndex != nil && viewModel.draggedPieceIndex! < viewModel.availablePieces.count
                                ? viewModel.availablePieces[viewModel.draggedPieceIndex!].color
                                : nil
                        )
                    }
                }
            }
        }
        .padding(BlockBlastConstants.cellSpacing * 2)
        .background(
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 12)
                    .fill(BlockBlastConstants.gridBackground.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(BlockBlastConstants.accentLime.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
                    .onAppear {
                        gridFrame = geometry.frame(in: .global)
                    }
                    .onChange(of: geometry.frame(in: .global)) { _, newFrame in
                        gridFrame = newFrame
                    }
            }
        )
    }
    
    private func isPreviewCell(row: Int, col: Int) -> Bool {
        guard let previewPos = viewModel.previewPosition,
              let pieceIndex = viewModel.draggedPieceIndex,
              pieceIndex < viewModel.availablePieces.count else {
            return false
        }
        
        let piece = viewModel.availablePieces[pieceIndex]
        for cell in piece.filledCells {
            if previewPos.row + cell.row == row && previewPos.col + cell.col == col {
                return true
            }
        }
        return false
    }
}

struct GridCellView: View {
    let cell: GridCell
    let isClearing: Bool
    let isPreview: Bool
    let cellSize: CGFloat
    var previewColor: Color?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: BlockBlastConstants.cellCornerRadius)
                .fill(cellColor)
                .frame(width: cellSize, height: cellSize)
            
            if cell.isFilled || isPreview {
                RoundedRectangle(cornerRadius: BlockBlastConstants.cellCornerRadius * 0.7)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(isPreview ? 0.4 : 0.3), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: cellSize * 0.85, height: cellSize * 0.85)
            }
            
            if isPreview {
                RoundedRectangle(cornerRadius: BlockBlastConstants.cellCornerRadius)
                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
                    .frame(width: cellSize, height: cellSize)
            }
        }
        .scaleEffect(isClearing ? 0.0 : 1.0)
        .opacity(isClearing ? 0.0 : 1.0)
        .animation(.easeInOut(duration: BlockBlastConstants.clearAnimationDuration), value: isClearing)
    }
    
    private var cellColor: Color {
        if isPreview {
            return (previewColor ?? BlockBlastConstants.accentLime).opacity(0.7)
        }
        if cell.isFilled, let color = cell.color {
            return color
        }
        return BlockBlastConstants.emptyCell
    }
}

struct PieceTrayView: View {
    @ObservedObject var viewModel: BlockBlastViewModel
    let gridFrame: CGRect
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(Array(viewModel.availablePieces.enumerated()), id: \.element.id) { index, piece in
                if !piece.isUsed {
                    DraggablePieceView(
                        piece: piece,
                        pieceIndex: index,
                        viewModel: viewModel,
                        gridFrame: gridFrame
                    )
                } else {
                    Color.clear
                        .frame(width: 60, height: 60)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(BlockBlastConstants.accentLime.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct DraggablePieceView: View {
    let piece: BlockPiece
    let pieceIndex: Int
    @ObservedObject var viewModel: BlockBlastViewModel
    let gridFrame: CGRect
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    
    private let cellSize: CGFloat = 20
    private let cellSpacing: CGFloat = 2
    
    var body: some View {
        BlockPieceView(piece: piece, cellSize: cellSize, cellSpacing: cellSpacing)
            .scaleEffect(isDragging ? 1.2 : 0.8)
            .offset(dragOffset)
            .opacity(isDragging && !viewModel.isValidPlacement ? 0.5 : 1.0)
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            viewModel.startDrag(pieceIndex: pieceIndex)
                        }
                        
                        dragOffset = value.translation
                        
                        let dropLocation = value.location
                        updatePreviewPositionWithSnapping(dropLocation: dropLocation)
                    }
                    .onEnded { value in
                        let dropLocation = value.location
                        handleDrop(at: dropLocation)
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = .zero
                            isDragging = false
                        }
                        viewModel.endDrag()
                    }
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
    }
    
    private func updatePreviewPositionWithSnapping(dropLocation: CGPoint) {
        let expandedFrame = gridFrame.insetBy(dx: -20, dy: -20)
        
        guard expandedFrame.contains(dropLocation) else {
            viewModel.previewPosition = nil
            viewModel.isValidPlacement = false
            return
        }
        
        let relativeX = dropLocation.x - gridFrame.minX
        let relativeY = dropLocation.y - gridFrame.minY
        
        let padding = BlockBlastConstants.cellSpacing * 2
        let gridCellSize = (gridFrame.width - padding * 2 - CGFloat(BlockBlastConstants.gridSize - 1) * BlockBlastConstants.cellSpacing) / CGFloat(BlockBlastConstants.gridSize)
        let cellWithSpacing = gridCellSize + BlockBlastConstants.cellSpacing
        
        let exactCol = (relativeX - padding) / cellWithSpacing
        let exactRow = (relativeY - padding) / cellWithSpacing
        
        let baseCol = Int(exactCol)
        let baseRow = Int(exactRow)
        
        let snapRange = 1
        var bestPosition: (row: Int, col: Int)? = nil
        var bestDistance: CGFloat = CGFloat.infinity
        
        for rowOffset in -snapRange...snapRange {
            for colOffset in -snapRange...snapRange {
                let testRow = baseRow + rowOffset
                let testCol = baseCol + colOffset
                
                guard testRow >= 0 && testRow < BlockBlastConstants.gridSize &&
                      testCol >= 0 && testCol < BlockBlastConstants.gridSize else {
                    continue
                }
                
                if viewModel.grid.canPlace(piece: piece, at: testRow, col: testCol) {
                    let cellCenterX = padding + CGFloat(testCol) * cellWithSpacing + gridCellSize / 2
                    let cellCenterY = padding + CGFloat(testRow) * cellWithSpacing + gridCellSize / 2
                    let distance = sqrt(pow(relativeX - cellCenterX, 2) + pow(relativeY - cellCenterY, 2))

                    if distance < bestDistance && distance < gridCellSize * 1.5 {
                        bestDistance = distance
                        bestPosition = (testRow, testCol)
                    }
                }
            }
        }
        
        if let position = bestPosition {
            viewModel.updatePreviewPosition(row: position.row, col: position.col)
        } else {
            viewModel.previewPosition = nil
            viewModel.isValidPlacement = false
        }
    }
    
    private func handleDrop(at location: CGPoint) {
        guard let position = viewModel.previewPosition,
              viewModel.isValidPlacement else {
            return
        }
        
        viewModel.placePiece(at: pieceIndex, gridRow: position.row, gridCol: position.col)
    }
}

struct BlockPieceView: View {
    let piece: BlockPiece
    let cellSize: CGFloat
    let cellSpacing: CGFloat
    
    var body: some View {
        VStack(spacing: cellSpacing) {
            ForEach(0..<piece.height, id: \.self) { row in
                HStack(spacing: cellSpacing) {
                    ForEach(0..<piece.width, id: \.self) { col in
                        if piece.shape[row][col] {
                            RoundedRectangle(cornerRadius: cellSize * 0.15)
                                .fill(piece.color)
                                .frame(width: cellSize, height: cellSize)
                                .overlay(
                                    RoundedRectangle(cornerRadius: cellSize * 0.1)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.white.opacity(0.3), Color.clear],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: cellSize * 0.8, height: cellSize * 0.8)
                                )
                                .shadow(color: piece.color.opacity(0.5), radius: 3, x: 0, y: 2)
                        } else {
                            Color.clear
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
    }
}
