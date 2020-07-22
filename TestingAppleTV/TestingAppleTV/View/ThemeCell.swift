//
//  ThemeCell.swift
//  TestingAppleTV
//
//  Created by Lia Kassardjian on 22/07/20.
//  Copyright © 2020 Guilherme Enes. All rights reserved.
//

import UIKit

class ThemeCell: UICollectionViewCell {
    
    @IBOutlet weak var themeImage: UIImageView! {
        didSet {
            self.themeImage.layer.cornerRadius = 10
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if isFocused {
            themeImage.adjustsImageWhenAncestorFocused = true
        } else {
            themeImage.adjustsImageWhenAncestorFocused = false
        }
    }
    
}
