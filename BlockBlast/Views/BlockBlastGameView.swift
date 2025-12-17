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
        VStack(spacing: 0) {
            TopBarView(viewModel: viewModel)
                .padding(.top, 10)
                .padding(.bottom, 20)
            
            Spacer()
            
            BlockGridView(
                viewModel: viewModel,
                gridFrame: $gridFrame
            )
            
            Spacer()
            
            PieceTrayView(viewModel: viewModel, gridFrame: gridFrame)
                .padding(.bottom, 30)
        }
    }
}

struct TopBarView: View {
    @ObservedObject var viewModel: BlockBlastViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                viewModel.exitToMenu()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 14))
                    .foregroundColor(BlockBlastConstants.cravrMaize)
                
                Text("\(viewModel.score)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: {
                    viewModel.toggleSound()
                }) {
                    Image(systemName: viewModel.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(viewModel.soundEnabled ? BlockBlastConstants.cravrGreen : .white.opacity(0.5))
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
                
                Button(action: {
                    viewModel.toggleHaptics()
                }) {
                    Image(systemName: viewModel.hapticsEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(viewModel.hapticsEnabled ? BlockBlastConstants.cravrGreen : .white.opacity(0.5))
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct BlockGridView: View {
    @ObservedObject var viewModel: BlockBlastViewModel
    @Binding var gridFrame: CGRect
    
    private let gridSize = BlockBlastConstants.gridSize
    private let cellSize = BlockBlastConstants.gridCellSize
    private let spacing = BlockBlastConstants.cellSpacing
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<gridSize, id: \.self) { col in
                        GridCellView(
                            cell: viewModel.grid.cells[row][col],
                            isClearing: viewModel.clearingRows.contains(row) || viewModel.clearingCols.contains(col),
                            isPreview: isPreviewCell(row: row, col: col) && viewModel.isValidPlacement,
                            cellSize: cellSize,
                            previewColor: getPreviewColor()
                        )
                    }
                }
            }
        }
        .padding(spacing * 2)
        .background(
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 16)
                    .fill(BlockBlastConstants.gridBackground)
                    .onAppear {
                        DispatchQueue.main.async {
                            gridFrame = geometry.frame(in: .global)
                        }
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
    
    private func getPreviewColor() -> Color? {
        guard let pieceIndex = viewModel.draggedPieceIndex,
              pieceIndex < viewModel.availablePieces.count else {
            return nil
        }
        return viewModel.availablePieces[pieceIndex].color
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
                .shadow(
                    color: (cell.isFilled || isPreview) ? glowColor.opacity(BlockBlastConstants.glowOpacity) : .clear,
                    radius: BlockBlastConstants.glowRadius,
                    x: 0,
                    y: 0
                )
            
            if cell.isFilled || isPreview {
                RoundedRectangle(cornerRadius: BlockBlastConstants.cellCornerRadius * 0.6)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.4), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: cellSize * 0.75, height: cellSize * 0.75)
            }
        }
        .scaleEffect(isClearing ? 0.0 : 1.0)
        .opacity(isClearing ? 0.0 : 1.0)
        .animation(.easeInOut(duration: BlockBlastConstants.clearAnimationDuration), value: isClearing)
    }
    
    private var cellColor: Color {
        if isPreview {
            return (previewColor ?? BlockBlastConstants.cravrGreen).opacity(0.8)
        }
        if cell.isFilled, let color = cell.color {
            return color
        }
        return BlockBlastConstants.emptyCell
    }
    
    private var glowColor: Color {
        if isPreview {
            return previewColor ?? BlockBlastConstants.cravrGreen
        }
        if let color = cell.color {
            return color
        }
        return .clear
    }
}

struct PieceTrayView: View {
    @ObservedObject var viewModel: BlockBlastViewModel
    let gridFrame: CGRect
    
    private let slotSize = BlockBlastConstants.traySlotSize
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(viewModel.availablePieces.enumerated()), id: \.element.id) { index, piece in
                ZStack {
                    if !piece.isUsed {
                        DraggablePieceView(
                            piece: piece,
                            pieceIndex: index,
                            viewModel: viewModel,
                            gridFrame: gridFrame
                        )
                    }
                }
                .frame(width: slotSize, height: slotSize)
            }
        }
        .frame(width: slotSize * 3 + 40)
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(BlockBlastConstants.cravrDarkSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
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
    
    private let trayCellSize = BlockBlastConstants.trayCellSize
    private let trayCellSpacing = BlockBlastConstants.trayCellSpacing
    
    var body: some View {
        TrayPieceView(piece: piece, cellSize: trayCellSize, cellSpacing: trayCellSpacing)
            .scaleEffect(isDragging ? 1.5 : 1.0)
            .opacity(isDragging && !viewModel.isValidPlacement ? 0.6 : 1.0)
            .offset(dragOffset)
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            viewModel.startDrag(pieceIndex: pieceIndex)
                        }
                        
                        dragOffset = value.translation
                        
                        let fingerLocation = value.location
                        findAndUpdatePreview(at: fingerLocation)
                    }
                    .onEnded { _ in
                        if viewModel.isValidPlacement {
                            viewModel.endDrag()
                        } else {
                            viewModel.resetDragState()
                        }
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = .zero
                            isDragging = false
                        }
                    }
            )
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isDragging)
    }
    
    private func findAndUpdatePreview(at point: CGPoint) {
        if let bestPos = viewModel.findBestPlacement(for: pieceIndex, near: point, gridFrame: gridFrame) {
            viewModel.updatePreviewPosition(row: bestPos.row, col: bestPos.col)
        } else {
            viewModel.previewPosition = nil
            viewModel.isValidPlacement = false
        }
    }
}

struct TrayPieceView: View {
    let piece: BlockPiece
    let cellSize: CGFloat
    let cellSpacing: CGFloat
    
    var body: some View {
        VStack(spacing: cellSpacing) {
            ForEach(0..<piece.height, id: \.self) { row in
                HStack(spacing: cellSpacing) {
                    ForEach(0..<piece.width, id: \.self) { col in
                        if piece.shape[row][col] {
                            ZStack {
                                RoundedRectangle(cornerRadius: cellSize * 0.2)
                                    .fill(piece.color)
                                    .frame(width: cellSize, height: cellSize)
                                    .shadow(
                                        color: piece.color.opacity(BlockBlastConstants.glowOpacity),
                                        radius: 6,
                                        x: 0,
                                        y: 0
                                    )
                                
                                RoundedRectangle(cornerRadius: cellSize * 0.15)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.4), Color.clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: cellSize * 0.7, height: cellSize * 0.7)
                            }
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
