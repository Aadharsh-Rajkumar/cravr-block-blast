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
                
                VStack(spacing: 20) {
                    BlockBlastPixelTitle()
                        .scaleEffect(logoPulseScale)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: logoPulseScale)
                        .onAppear {
                            logoPulseScale = 1.05
                        }
                    
                    HStack(spacing: 8) {
                        ForEach(0..<5, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 6)
                                .fill(BlockBlastConstants.blockColors[index % BlockBlastConstants.blockColors.count])
                                .frame(width: 30, height: 30)
                                .shadow(color: BlockBlastConstants.blockColors[index % BlockBlastConstants.blockColors.count].opacity(0.5), radius: 4, x: 0, y: 2)
                                .offset(y: blockBounce)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.1),
                                    value: blockBounce
                                )
                        }
                    }
                    .onAppear {
                        blockBounce = -10
                    }
                }
                
                VStack(spacing: 10) {
                    Text("HIGH SCORE")
                        .font(.system(size: BlockBlastConstants.screenWidth * 0.045, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 3, x: 2, y: 2)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: BlockBlastConstants.screenWidth * 0.03)
                            .frame(width: BlockBlastConstants.screenWidth * 0.35, height: BlockBlastConstants.screenHeight * 0.065)
                            .foregroundColor(.black.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: BlockBlastConstants.screenWidth * 0.03)
                                    .stroke(BlockBlastConstants.accentLime.opacity(0.5), lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                        
                        Text("\(viewModel.highScore)")
                            .font(.system(size: BlockBlastConstants.screenWidth * 0.07, weight: .bold, design: .rounded))
                            .foregroundColor(BlockBlastConstants.accentYellow)
                            .shadow(color: .black.opacity(0.8), radius: 3, x: 2, y: 2)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    Text("TAP ANYWHERE")
                        .font(.system(size: BlockBlastConstants.screenWidth * 0.055, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 3, x: 2, y: 2)
                    
                    Text("TO START")
                        .font(.system(size: BlockBlastConstants.screenWidth * 0.055, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.8), radius: 3, x: 2, y: 2)
                }
                .scaleEffect(logoPulseScale)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: logoPulseScale)
                
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.startGame()
            }
            
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: BlockBlastConstants.screenWidth * 0.06, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 3, x: 2, y: 2)
                            .padding(BlockBlastConstants.screenWidth * 0.04)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

struct BlockBlastPixelTitle: View {
    let blockColors: [Color] = [
        BlockBlastConstants.accentYellow,
        BlockBlastConstants.accentLime,
        BlockBlastConstants.accentYellow,
        BlockBlastConstants.accentLime,
        BlockBlastConstants.accentYellow,
    ]
    
    let blastColors: [Color] = [
        BlockBlastConstants.accentLime,
        BlockBlastConstants.accentYellow,
        BlockBlastConstants.accentLime,
        BlockBlastConstants.accentYellow,
        BlockBlastConstants.accentLime,
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array("BLOCK".enumerated()), id: \.offset) { index, char in
                    PixelLetterView(
                        char: char,
                        color: blockColors[index % blockColors.count],
                        size: BlockBlastConstants.screenWidth * 0.1
                    )
                }
            }
            
            HStack(spacing: 0) {
                ForEach(Array("BLAST".enumerated()), id: \.offset) { index, char in
                    PixelLetterView(
                        char: char,
                        color: blastColors[index % blastColors.count],
                        size: BlockBlastConstants.screenWidth * 0.1
                    )
                }
            }
        }
        .padding(.horizontal, BlockBlastConstants.screenWidth * 0.05)
    }
}

struct PixelLetterView: View {
    let char: Character
    let color: Color
    let size: CGFloat
    var widthScale: CGFloat = 1.3
    var outlineOffset: CGFloat = 1.5
    
    private var pixelFont: Font {
        if let uiFont = UIFont(name: "PressStart2P-Regular", size: size) {
            return Font(uiFont)
        } else {
            return .system(size: size, weight: .bold, design: .monospaced)
        }
    }
    
    var body: some View {
        ZStack {
            Group {
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: -outlineOffset, y: 0)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: outlineOffset, y: 0)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: 0, y: -1)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: 0, y: 1)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: -outlineOffset, y: -1)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: outlineOffset, y: -1)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: -outlineOffset, y: 1)
                Text(String(char)).font(pixelFont).foregroundColor(.black).offset(x: outlineOffset, y: 1)
            }
            
            Text(String(char))
                .font(pixelFont)
                .foregroundColor(color)
        }
        .scaleEffect(x: widthScale, y: 1.0, anchor: .center)
    }
}
