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
    
    @IBOutlet weak var photoSavedLBL: UILabel!
    
    var metalView: MTKView {
        return self.view as! MTKView
    }
    
    @IBOutlet weak var descriptionView: DescriptionView!
    @IBOutlet weak var themeCollectionView: UICollectionView!
    
    var set: Sets = .some
    var setIndex: Int = 0
    var renderer: Renderer?
    
    var collectionViewController: CollectionViewController?
    
    let introductionText = "Para ver mais informações sobre esta arte generativa, dê um tap no controle. \nPara capturar uma imagem desta arte, dê um clique no controle."
    
    var context: NSManagedObjectContext?
    
    var audioPlayer: AVAudioPlayer?
    var animator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut)
    var animatorLBL = UIViewPropertyAnimator(duration: 1, curve: .easeInOut)
    var timer: Timer?
    var timerLBL: Timer?
    var descriptionIsShown = false
    var saveLabelIsShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        setupMetal()
        
        startBackgroundMusic()
        photoSavedLBLedit()
        
        setupTagGesture()
        descriptionView.descriptionText.text = introductionText
        
        setupCollectionView()
        collectionViewController = CollectionViewController(set: set)
        themeCollectionView.delegate = collectionViewController
        themeCollectionView.dataSource = collectionViewController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        descriptionView.alpha = 0
        animator.addAnimations {
            self.descriptionView.isHidden = false
            self.descriptionView.alpha = 1
        }
        descriptionIsShown = true
        saveLabelIsShown = true
        
        animator.startAnimation()
        
        setTimer(with: 5)
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
    
    func setupCollectionView() {
        themeCollectionView.layer.cornerRadius = 20
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = themeCollectionView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        themeCollectionView.backgroundView = blurEffectView
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
    
    func setupTagGesture() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func didTap(gesture: UITapGestureRecognizer) {
        if descriptionIsShown {
            timer?.invalidate()
            animator.stopAnimation(true)
            animator.addAnimations ({
                self.descriptionView.alpha = 0
            })
            
            animator.addCompletion { (completion) in
                self.setTimer(with: 0.1)
            }
            animator.startAnimation()
            descriptionIsShown = true
            
        } else {
            showReverseAnimation()
            setTimer(with: 3)
        }
        
        
        if saveLabelIsShown {
            timerLBL?.invalidate()
            animatorLBL.stopAnimation(true)
            animatorLBL.addAnimations {
                self.photoSavedLBL.alpha = 1
            }
            
            animatorLBL.addCompletion { (completion) in
                self.setTimerforLBL(with: 0.1)
            }
            animatorLBL.startAnimation()
            saveLabelIsShown = true
        } else {
            showReverseAnimationLBL()
            setTimerforLBL(with: 3)
        }
    }
    
    @objc func showReverseAnimation() {
        animator.stopAnimation(true)
        animator.addAnimations ({
            self.descriptionView.alpha = self.descriptionIsShown ? 0 : 1
        })
        
        animator.addCompletion { (completion) in
            if self.descriptionView.descriptionText.text == self.introductionText {
                self.descriptionView.descriptionText.text = artData[self.setIndex].description
            }
        }
        animator.startAnimation()
        descriptionIsShown = !descriptionIsShown
        
        if descriptionIsShown {
            setTimer(with: 10)
        }
    }
    
    
    @objc func showReverseAnimationLBL() {
        animatorLBL.addAnimations ({
            self.photoSavedLBL.alpha = self.saveLabelIsShown ? 0 : 1
        })
        animatorLBL.startAnimation()
        saveLabelIsShown = !saveLabelIsShown
        
        if saveLabelIsShown {
            setTimerforLBL(with: 3)
        }
    }
    
    func setTimer(with duration: TimeInterval) {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(
            timeInterval: duration,
            target: self,
            selector: #selector(self.showReverseAnimation),
            userInfo: nil,
            repeats: false
        )
    }
    
    func setTimerforLBL(with duration: TimeInterval) {
        self.timerLBL?.invalidate()
        self.timerLBL = Timer.scheduledTimer(
            timeInterval: duration,
            target: self,
            selector: #selector(self.showReverseAnimationLBL),
            userInfo: nil,
            repeats: false
        )
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
    }
    
    func photoSavedLBLedit() {
        photoSavedLBL.layer.cornerRadius = photoSavedLBL.frame.size.height/4
        photoSavedLBL.layer.masksToBounds = true
        
        photoSavedLBL.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        
        photoSavedLBL.alpha = 0
    }
    
}
