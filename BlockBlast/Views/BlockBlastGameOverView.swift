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
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("GAME OVER")
                    .font(.system(size: BlockBlastConstants.screenWidth * 0.1, weight: .bold, design: .rounded))
                    .foregroundColor(BlockBlastConstants.accentLime)
                    .shadow(color: .black, radius: 4, x: 2, y: 2)

                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("SCORE")
                            .font(.system(size: BlockBlastConstants.screenWidth * 0.04, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(viewModel.score)")
                            .font(.system(size: BlockBlastConstants.screenWidth * 0.12, weight: .bold, design: .rounded))
                            .foregroundColor(BlockBlastConstants.accentYellow)
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .frame(width: BlockBlastConstants.screenWidth * 0.4)
                    
                    VStack(spacing: 8) {
                        Text("BEST")
                            .font(.system(size: BlockBlastConstants.screenWidth * 0.035, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(viewModel.highScore)")
                            .font(.system(size: BlockBlastConstants.screenWidth * 0.08, weight: .bold, design: .rounded))
                            .foregroundColor(BlockBlastConstants.accentLime)
                    }

                    if viewModel.score >= viewModel.highScore && viewModel.score > 0 {
                        Text("🏆 NEW BEST!")
                            .font(.system(size: BlockBlastConstants.screenWidth * 0.05, weight: .bold, design: .rounded))
                            .foregroundColor(BlockBlastConstants.accentYellow)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(BlockBlastConstants.accentLime.opacity(0.3))
                            )
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(BlockBlastConstants.primaryGreen.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(BlockBlastConstants.accentLime.opacity(0.4), lineWidth: 2)
                        )
                )
                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 15) {
                    Button(action: {
                        viewModel.startGame()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("PLAY AGAIN")
                        }
                        .font(.system(size: BlockBlastConstants.screenWidth * 0.045, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [BlockBlastConstants.accentYellow, BlockBlastConstants.accentLime],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: BlockBlastConstants.accentLime.opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                    
                    Button(action: {
                        viewModel.resetGame()
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("MENU")
                        }
                        .font(.system(size: BlockBlastConstants.screenWidth * 0.04, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .stroke(BlockBlastConstants.accentLime.opacity(0.6), lineWidth: 2)
                        )
                    }
                }
            }
            .scaleEffect(showContent ? 1.0 : 0.8)
            .opacity(showContent ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showContent = true
                }
            }
        }
    }
}
