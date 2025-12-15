//
//  BlockBlastMenuView.swift
//  BlockBlast
//
//  Created by Aadharsh Rajkumar on 12/15/25.
//

import SwiftUI
import Combine

struct BlockBlastMenuView: View {
    @ObservedObject var viewModel: BlockBlastViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Block Blast")
                .font(.largeTitle)
                .fontWeight(.bold)

            Button("Start") {
                viewModel.startGame()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
