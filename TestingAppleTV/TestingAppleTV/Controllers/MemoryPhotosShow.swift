//
//  MemoryPhotosShow.swift
//  TestingAppleTV
//
//  Created by Guilherme Enes on 15/07/20.
//  Copyright © 2020 Guilherme Enes. All rights reserved.
//

import Foundation
import UIKit

class MemoryPhotosShow: UIViewController {
    
    @IBOutlet weak var memoryPhotoPresentationIMGView: UIImageView!
    
    var imageToPresent = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoryPhotoPresentationIMGView.image = imageToPresent
        
        
        
    }
}
