//
//  BlockBlast_ContentView.swift
//  BlockBlast
//
//  Created by Aadharsh Rajkumar on 12/15/25.
//
//  This is the main entry point for Block Blast.
//  Simply add BlockBlast_ContentView() to integrate into any app.
//

import SwiftUI

struct BlockBlast_ContentView: View {
    @StateObject private var viewModel = BlockBlastViewModel()
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image("GameBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
            
            switch viewModel.gameState {
            case .menu:
                BlockBlastMenuView(viewModel: viewModel)
                    .transition(.opacity)
            case .playing:
                BlockBlastGameView(viewModel: viewModel)
                    .transition(.opacity)
            case .gameOver:
                BlockBlastGameOverView(viewModel: viewModel)
                    .transition(.opacity)
            }
            
            if viewModel.showComboOverlay {
                ComboOverlayView(text: viewModel.comboText, linesCleared: viewModel.linesCleared)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: BlockBlastConstants.menuTransitionDuration), value: viewModel.gameState)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.showComboOverlay)
    }
}

struct ComboOverlayView: View {
    let text: String
    let linesCleared: Int
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0
    
    var body: some View {
        VStack(spacing: 8) {
            Text(text)
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [BlockBlastConstants.cravrMaize, BlockBlastConstants.cravrPumpkin],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: BlockBlastConstants.cravrPumpkin.opacity(0.8), radius: 12, x: 0, y: 0)
                .shadow(color: .black.opacity(0.5), radius: 4, x: 2, y: 2)
            
            if linesCleared > 1 {
                Text("+\(linesCleared * BlockBlastConstants.lineClearBonus * BlockBlastConstants.comboMultiplier(for: linesCleared))")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                scale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.5)) {
                    scale = 1.0
                    opacity = 0.0
                }
            }
        }
    }
}

#Preview {
    BlockBlast_ContentView()
}
