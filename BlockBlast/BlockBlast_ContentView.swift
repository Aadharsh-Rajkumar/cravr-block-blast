//
//  BlockBlast_ContentView.swift
//  BlockBlast
//
//  Created by Aadharsh Rajkumar on 12/15/25.
//
//

import SwiftUI

struct BlockBlast_ContentView: View {
    @StateObject private var viewModel = BlockBlastViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    BlockBlastConstants.deepGreen,
                    BlockBlastConstants.primaryGreen,
                    BlockBlastConstants.deepGreen
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            StarsBackgroundView()
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
        }
        .animation(.easeInOut(duration: BlockBlastConstants.menuTransitionDuration), value: viewModel.gameState)
    }
}

struct StarsBackgroundView: View {
    @State private var stars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<30, id: \.self) { index in
                    if index < stars.count {
                        Circle()
                            .fill(Color.white)
                            .frame(width: stars[index].size, height: stars[index].size)
                            .position(x: stars[index].x, y: stars[index].y)
                            .opacity(stars[index].opacity)
                    }
                }
            }
            .onAppear {
                generateStars(in: geometry.size)
            }
        }
    }
    
    private func generateStars(in size: CGSize) {
        stars = (0..<30).map { _ in
            (
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.2...0.5)
            )
        }
    }
}

#Preview {
    BlockBlast_ContentView()
}
