//
//  BlockBlastGameOverView.swift
//  BlockBlast
//
//  Created by Aadharsh Rajkumar on 12/15/25.
//

import SwiftUI

struct BlockBlastGameOverView: View {
    @ObservedObject var viewModel: BlockBlastViewModel
    @State private var showContent = false
    @State private var isNewHighScore = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("GAME OVER")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [BlockBlastConstants.cravrPumpkin, BlockBlastConstants.cravrMaize],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: BlockBlastConstants.cravrPumpkin.opacity(0.5), radius: 10, x: 0, y: 0)
                
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("SCORE")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("\(viewModel.score)")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    if isNewHighScore {
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(BlockBlastConstants.cravrMaize)
                            Text("NEW BEST!")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(BlockBlastConstants.cravrMaize)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(BlockBlastConstants.cravrMaize.opacity(0.2))
                        )
                    }
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 80, height: 1)
                    
                    VStack(spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 12))
                                .foregroundColor(BlockBlastConstants.cravrMaize.opacity(0.7))
                            Text("BEST")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Text("\(viewModel.highScore)")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(BlockBlastConstants.cravrDarkSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                
                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.startGame()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18, weight: .bold))
                            Text("PLAY AGAIN")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [BlockBlastConstants.cravrGreen, BlockBlastConstants.cravrGreen.opacity(0.8)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: BlockBlastConstants.cravrGreen.opacity(0.4), radius: 10, x: 0, y: 4)
                        )
                    }
                    
                    Button(action: {
                        viewModel.resetGame()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 16))
                            Text("MENU")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal, 40)
            }
            .padding(20)
            .scaleEffect(showContent ? 1.0 : 0.8)
            .opacity(showContent ? 1.0 : 0.0)
            .onAppear {
                isNewHighScore = viewModel.score >= viewModel.highScore && viewModel.score > 0
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showContent = true
                }
            }
        }
    }
}
