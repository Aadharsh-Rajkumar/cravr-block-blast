//
//  BlockBlastService.swift
//  BlockBlast
//
//  Created by Aadharsh Rajkumar on 12/15/25.
//

import Foundation
import Combine

final class BlockBlastService {

    func fetchBlockTypes() -> [String] {
        return ["normal", "bomb", "bonus"]
    }

    func loadGameData(completion: @escaping ([String]) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            completion(["normal", "bomb", "bonus"])
        }
    }
}
