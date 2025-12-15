//
//  BlockBlastGameView.swift
//  BlockBlast
//
//  Created by Aadharsh Rajkumar on 12/15/25.
//

import SwiftUI
import Combine

struct BlockBlastGameView: View {
    @ObservedObject var viewModel: BlockBlastViewModel

    var body: some View {
        VStack {
            Text("Block Blast")
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()

            Text("Gameplay grid placeholder")
                .foregroundStyle(.secondary)

            Spacer()

            Button("End Game") {
                viewModel.endGame()
            }
        }
        .padding()
    }
}
