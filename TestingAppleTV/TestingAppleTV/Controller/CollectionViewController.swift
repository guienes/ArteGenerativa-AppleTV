//
//  CollectionViewController.swift
//  TestingAppleTV
//
//  Created by Lia Kassardjian on 22/07/20.
//  Copyright © 2020 Guilherme Enes. All rights reserved.
//

import UIKit

class CollectionViewController: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var set: Sets
    var imageName: [String]
    weak var viewController: GenerativeArtVC?
    
    var defaultSize = CGSize(width: 350, height: 200)
    var focusedSize = CGSize(width: 350, height: 200)
    
    
    init(set: Sets, viewController: GenerativeArtVC) {
        self.set = set
        self.viewController = viewController
        
        imageName = ["paleta1", "paleta2", "paleta3", "paleta4"]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageName.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "themeCell",
            for: indexPath
            ) as? ThemeCell else { return UICollectionViewCell() }
        
        var name = ""
        
        switch set {
        case .julia:
            name = "julia"
        default:
            name = "julia"//"mandelbrot"
        }
        
        let image = UIImage(named: "\(name)_\(imageName[indexPath.row])")
        cell.themeImage.image = image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        defaultSize = CGSize(width: 350, height: collectionView.frame.size.height - 60)
        focusedSize = CGSize(width: 330, height: collectionView.frame.size.height - 40)
        
        return defaultSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        let viewWidth = Int(collectionView.frame.size.width)
        let remainingSpace = viewWidth - imageName.count * 350 - 60
        let spacing = CGFloat(remainingSpace / (imageName.count - 1))
        
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let theme = Theme(rawValue: imageName[indexPath.row]),
            let view = viewController?.metalView
            else { return }
        
        viewController?.renderer?.changePattern(for: set, theme: theme, in: view)
    }
    
}
