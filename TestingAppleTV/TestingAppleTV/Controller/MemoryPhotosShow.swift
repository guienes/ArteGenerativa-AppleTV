//
//  MemoryPhotosShow.swift
//  TestingAppleTV
//
//  Created by Guilherme Enes on 15/07/20.
//  Copyright © 2020 Guilherme Enes. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class MemoryPhotosShow: UIViewController {
    
    @IBOutlet weak var memoryPhotoPresentationIMGView: UIImageView!
    
    var imageToPresent = UIImage()
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoryPhotoPresentationIMGView.image = imageToPresent
        
    startBackgroundMusic()
   }
    
     override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    // Music
    for press in presses {
        if press.type == .playPause {
            if (audioPlayer!.isPlaying == true) {
                audioPlayer!.stop()
            } else {
                audioPlayer!.play()
            }
        }
        
        if press.type == .menu {
            MusicPlayer.shared.stopPlaying()
        }
        }
    }
    func startBackgroundMusic() {
    if let bundle = Bundle.main.path(forResource: "bensound-memories", ofType: "mp3") {
        let backgroundMusic = NSURL(fileURLWithPath: bundle)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf:backgroundMusic as URL)
            guard let audioPlayer = audioPlayer else { return }
            audioPlayer.numberOfLoops = -1
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
            if audioPlayer.isPlaying {
                audioPlayer.play()
            } else {
                audioPlayer.stop()
            }
            
        } catch {
            print(error)
        }
    }
}
}
