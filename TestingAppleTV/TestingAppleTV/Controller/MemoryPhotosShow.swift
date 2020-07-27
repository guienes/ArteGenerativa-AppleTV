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
    
    @IBOutlet weak var memoryImageView: UIImageView!
    
    var memories = [Memory]()
    var currentIndex: Int = 0
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImage()
        startBackgroundMusic()
        setupSwipeGesture()
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
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
    
    func setupSwipeGesture() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action:  #selector(didSwipe))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action:  #selector(didSwipe))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func didSwipe(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            currentIndex += 1
            if currentIndex >= memories.count {
                currentIndex = 0
            }
        } else {
            currentIndex -= 1
            if currentIndex < 0 {
                currentIndex = memories.count - 1
            }
        }
        
        setImage()
    }
    
    func setImage() {
        guard let imageData = memories[currentIndex].image else { return }
        memoryImageView.image = UIImage(data: imageData)
    }
    
}
