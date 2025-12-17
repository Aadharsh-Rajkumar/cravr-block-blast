//
//  BlockBlast_Audio.swift
//  BlockBlast
//
//  Created by Aadharsh Rajkumar on 12/17/25.
//

import Foundation
import AVFoundation

class BlockBlast_Audio {
    static let shared = BlockBlast_Audio()
    
    private var pickupPlayer: AVAudioPlayer?
    private var placePlayer: AVAudioPlayer?
    private var clearPlayer: AVAudioPlayer?
    
    private init() {
        preparePlayers()
    }
    
    private func preparePlayers() {
        pickupPlayer = createPlayer(filename: "block_pickup", ext: "mp3")
        placePlayer = createPlayer(filename: "block_place", ext: "mp3")
        clearPlayer = createPlayer(filename: "row_clear", ext: "mp3")
    }
    
    private func createPlayer(filename: String, ext: String) -> AVAudioPlayer? {
        if let url = Bundle.main.url(forResource: filename, withExtension: ext) {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                return player
            } catch {
                print("Error loading sound \(filename).\(ext): \(error)")
            }
        } else {
            if let url = Bundle.main.url(forResource: "GameSounds/" + filename, withExtension: ext) {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                     return player
                } catch {
                    print("Error loading sound \(filename).\(ext) from GameSounds: \(error)")
                }
            } else {
                 print("Could not find sound file: \(filename).\(ext)")
            }
        }
        return nil
    }
    
    func playPickup() {
        guard let player = pickupPlayer else { return }
        if player.isPlaying {
            player.stop()
            player.currentTime = 0
        }
        player.play()
    }
    
    func playPlace() {
        guard let player = placePlayer else { return }
        if player.isPlaying {
            player.stop()
            player.currentTime = 0
        }
        player.play()
    }
    
    func playClear() {
        guard let player = clearPlayer else { return }
        if player.isPlaying {
            player.stop()
            player.currentTime = 0
        }
        player.play()
    }
}
