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

class GenerativeArtVC: UIViewController{
    
    var metalView: MTKView {
        return self.view as! MTKView
    }
    
    var set: Sets = .some
    var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetal()
        renderer?.animate = true
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
