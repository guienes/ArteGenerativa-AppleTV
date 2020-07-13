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

class GenerativeArtVC: UIViewController{
    
    var metalView: MTKView {
        return self.view as! MTKView
    }
    
    var set: Sets = .some
    var renderer: Renderer?
    
    var context: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        setupMetal()
        renderer?.animate = true
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
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
    
    func setupMetal() {
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
        metalView.preferredFramesPerSecond = 60
        metalView.clearColor = MTLClearColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0)
        metalView.framebufferOnly = false
        
        self.renderer = Renderer(device: metalView.device!, metalView: metalView, set: set)
        metalView.delegate = self.renderer
    }
}
