//
//  MusicPlayer.swift
//  TestingAppleTV
//
//  Created by Tamara Erlij on 14/07/20.
//  Copyright © 2020 Guilherme Enes. All rights reserved.
//

import Foundation
import AVFoundation

class MusicPlayer {
    static let shared = MusicPlayer()
    var audioPlayer: AVAudioPlayer?
   
    public func stopPlaying() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        audioPlayer.stop()
    }
}
