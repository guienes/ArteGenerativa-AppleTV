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
    
    var descriptionAnimator: AnimationController?
    var labelAnimator: AnimationController?
    var collectionAnimator: AnimationController?
    
    var audioPlayer: AVAudioPlayer?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        setupMetal()
        
        startBackgroundMusic()
        photoSavedLBLedit()
        
        setupTagGesture()
        setupSwipeGesture()
        descriptionView.descriptionText.text = introductionText
        
        setupCollectionView()
        collectionViewController = CollectionViewController(set: set, viewController: self)
        themeCollectionView.delegate = collectionViewController
        themeCollectionView.dataSource = collectionViewController
        
        descriptionAnimator = AnimationController(view: descriptionView, duration: 10)
        labelAnimator = AnimationController(view: photoSavedLBL, duration: 3)
        collectionAnimator = AnimationController(view: themeCollectionView, duration: 3)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        descriptionView.alpha = 0
        descriptionView.isHidden = false
        
        descriptionAnimator?.setAnimation(animation: descriptionAnimator?.fadeInOut ?? {})
        
        descriptionAnimator?.animate(delay: 5, reverts: true, with: {
            (completion) in
            if self.descriptionView.descriptionText.text == self.introductionText {
                self.descriptionView.descriptionText.text = artData[self.setIndex].description
            }
        })
        
        labelAnimator?.setAnimation(animation: labelAnimator?.fadeInOut ?? {})
        
        collectionAnimator?.setAnimation {
            let viewHeight = self.view.frame.height
            let collectionHeight = self.themeCollectionView.frame.height
            let y = self.themeCollectionView.center.y
            let distance = viewHeight - y + collectionHeight / 2
            
            self.themeCollectionView.center.y += distance + collectionHeight
        }
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
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func setupSwipeGesture() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        swipe.direction = .down
        self.view.addGestureRecognizer(swipe)
    }
    
    @objc func didTap(gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        if !view.isDescendant(of: themeCollectionView) {
            if descriptionAnimator!.isVisible {
                descriptionAnimator?.animate(delay: 0.1, reverts: true, with:  {
                    (completion) in
                    if self.descriptionView.descriptionText.text == self.introductionText {
                        self.descriptionView.descriptionText.text = artData[self.setIndex].description
                    }
                })
                
            } else {
                descriptionAnimator?.animate(delay: 10, reverts: true, with: nil)
            }
            
            captureImage()
        }
    }
    
    @objc func didSwipe(gesture: UISwipeGestureRecognizer) {
        print("Swipe")
        collectionAnimator?.animate(delay: 1, reverts: false, with: { (completion) in
            self.themeCollectionView.isHidden = true
            self.themeCollectionView.isUserInteractionEnabled = false
        })
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
        photoSavedLBL.layer.cornerRadius = photoSavedLBL.frame.size.height/4
        photoSavedLBL.layer.masksToBounds = true
        
        photoSavedLBL.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        
        photoSavedLBL.alpha = 0
    }
    
}
