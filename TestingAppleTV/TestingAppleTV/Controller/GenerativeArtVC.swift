//
//  GenerativeJuliaVC.swift
//  TestingAppleTV
//
//  Created by Guilherme Enes on 09/07/20.
//  Copyright © 2020 Guilherme Enes. All rights reserved.
//

import Foundation
import UIKit
import MetalKit
import CoreData
import AVKit

class GenerativeArtVC: UIViewController {
        
    var metalView: MTKView {
        return self.view as! MTKView
    }
    
    @IBOutlet weak var descriptionView: DescriptionView!
    @IBOutlet weak var photoSavedLabel: UIVisualEffectView!
    
    var set: Sets = .some
    var setIndex: Int = 0
    var renderer: Renderer?
    
    var themes: [Theme] = [.main, .lightning, .peace, .blackAndWhite]
    var currentTheme = 0
        
    let introductionText = "Para ver mais informações sobre esta arte generativa, dê um tap no controle. \nPara capturar uma imagem desta arte, dê um clique no controle. \nArraste para o lado para alterar a cor da arte generativa."
    
    var context: NSManagedObjectContext?
    
    var descriptionAnimator: AnimationController?
    var labelAnimator: AnimationController?
    
    var audioPlayer: AVAudioPlayer?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        setupMetal()
        
        startBackgroundMusic()
        photoSavedLBLedit()
        
        setupSwipeGesture()
        descriptionView.descriptionText.text = introductionText
        
        descriptionAnimator = AnimationController(view: descriptionView, duration: 30)
        labelAnimator = AnimationController(view: photoSavedLabel, duration: 3)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        descriptionView.alpha = 0
        descriptionView.isHidden = false
        
        descriptionAnimator?.setAnimation(animation: descriptionAnimator?.fadeInOut ?? {})
        
        labelAnimator?.setAnimation(animation: labelAnimator?.fadeInOut ?? {})
    }
    
    override func viewDidAppear(_ animated: Bool) {
        descriptionAnimator?.animate(delay: 15, reverts: true, with: {
            (completion) in
            if self.descriptionView.descriptionText.text == self.introductionText {
                self.descriptionView.descriptionText.text = artData[self.setIndex].description
            }
        })
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if press.type == .playPause {
                if (audioPlayer!.isPlaying == true) {
                    audioPlayer!.stop()
                    metalView.isPaused =  true
                } else {
                    audioPlayer!.play()
                    metalView.isPaused =  false
                }
            }
            
            if press.type == .menu {
                MusicPlayer.shared.stopPlaying()
            }
            
            if press.type == .select {
                captureImage()
            }
        }
    }
    
    func setupMetal() {
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
        metalView.preferredFramesPerSecond = 60
        metalView.clearColor = MTLClearColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0)
        metalView.framebufferOnly = false
        
        self.renderer = Renderer(device: metalView.device!, metalView: metalView, set: set, theme: .main)
        metalView.delegate = self.renderer
    }
    
    func startBackgroundMusic() {
        var songName = ""
        switch set {
        case .julia:
            songName = "bensound-birthofahero"
        case .mandelbrot:
            songName = "bensound-tomorrow"
        case.some:
            songName = "bensound-memories"
        }
        
        if let bundle = Bundle.main.path(forResource: "\(songName.self)", ofType: "mp3") {
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for item in touches {
            if item.type == .indirect{
                if descriptionAnimator!.isVisible {
                    descriptionAnimator?.animate(delay: 0.1, reverts: true, with:  {
                        (completion) in
                        if self.descriptionView.descriptionText.text == self.introductionText {
                            self.descriptionView.descriptionText.text = artData[self.setIndex].description
                        }
                    })
                    
                } else {
                    descriptionAnimator?.animate(delay: 20, reverts: true, with: nil)
                }
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
            currentTheme += 1
            if currentTheme >= themes.count {
                currentTheme = 0
            }
        } else {
            currentTheme -= 1
            if currentTheme <= 0 {
                currentTheme = themes.count - 1
            }
        }
        renderer?.changePattern(for: set, theme: themes[currentTheme], in: metalView)
    }
    
    func captureImage() {
        guard let context = self.context,
            let texture = metalView.currentDrawable?.texture,
            let image = texture.toImage()
            else { return }
        
        let uiimage = UIImage(cgImage: image)
        
        let newMemory = NSEntityDescription.insertNewObject(forEntityName: "Memory", into: context) as! Memory
        newMemory.set = self.set.rawValue
        newMemory.image = uiimage.pngData()
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        
        if labelAnimator!.isVisible {
            labelAnimator?.animate(delay: 0.1, reverts: true, with: nil)
        } else {
            labelAnimator?.animate(delay: 3, reverts: true, with: nil)
        }
    }
    
    func photoSavedLBLedit() {
        photoSavedLabel.layer.cornerRadius = photoSavedLabel.frame.size.height / 4
        photoSavedLabel.layer.masksToBounds = true
                
        photoSavedLabel.alpha = 0
    }
    
}
