//
//  BlockBlastModel.swift
//  BlockBlast
//
//  Created by Aadharsh Rajkumar on 12/15/25.
//

import Foundation

struct Block: Identifiable {
    let id = UUID()
    var type: String
    var isActive: Bool
}

struct Grid {
    var rows: Int
    var columns: Int
    var blocks: [[Block]]

    init(rows: Int = 9, columns: Int = 13) {
        self.rows = rows
        self.columns = columns
        self.blocks = Array(repeating: Array(repeating: Block(type: "normal", isActive: true), count: columns), count: rows)
    }
}
