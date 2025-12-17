//
//  BlockBlastMenuView.swift
//  BlockBlast
//
//  Created by Aadharsh Rajkumar on 12/15/25.
//

import SwiftUI

struct BlockBlastMenuView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: BlockBlastViewModel
    @State private var logoPulseScale: CGFloat = 0.95
    @State private var blockBounce: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("BLOCK")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [BlockBlastConstants.cravrGreen, BlockBlastConstants.cravrGreen.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: BlockBlastConstants.cravrGreen.opacity(0.6), radius: 12, x: 0, y: 0)
                    
                    Text("BLAST")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [BlockBlastConstants.cravrMaize, BlockBlastConstants.cravrPumpkin],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: BlockBlastConstants.cravrPumpkin.opacity(0.6), radius: 12, x: 0, y: 0)
                        .offset(y: -8)
                    
                    HStack(spacing: 12) {
                        ForEach(0..<4, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(BlockBlastConstants.blockColors[index])
                                .frame(width: 32, height: 32)
                                .shadow(
                                    color: BlockBlastConstants.blockColors[index].opacity(0.7),
                                    radius: 10,
                                    x: 0,
                                    y: 0
                                )
                                .offset(y: blockBounce)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.12),
                                    value: blockBounce
                                )
                        }
                    }
                    .padding(.top, 10)
                    .onAppear {
                        blockBounce = -8
                    }
                }
                .scaleEffect(logoPulseScale)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: logoPulseScale)
                .onAppear {
                    logoPulseScale = 1.02
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(BlockBlastConstants.cravrMaize)
                        Text("BEST SCORE")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Text("\(viewModel.highScore)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(BlockBlastConstants.cravrDarkSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                
                Spacer()
                
                Button(action: {
                    viewModel.startGame()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 22))
                        Text("PLAY")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 60)
                    .padding(.vertical, 18)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [BlockBlastConstants.cravrGreen, BlockBlastConstants.cravrGreen.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: BlockBlastConstants.cravrGreen.opacity(0.5), radius: 15, x: 0, y: 5)
                    )
                }
                .scaleEffect(logoPulseScale)
                
                Spacer()
            }
            
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                Spacer()
            }
        }
    }
}
