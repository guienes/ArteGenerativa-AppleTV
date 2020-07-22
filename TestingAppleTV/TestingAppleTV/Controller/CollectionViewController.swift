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
    
    init(set: Sets) {
        self.set = set
        
        imageName = ["julia_paleta1", "julia_paleta2", "julia_paleta3", "julia_paleta4"]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageName.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "themeCell",
            for: indexPath
            ) as? ThemeCell else { return UICollectionViewCell() }
        
        let image = UIImage(named: imageName[indexPath.row])
        cell.themeImage.image = image
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 350, height: collectionView.frame.size.height - 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        let viewWidth = Int(collectionView.frame.size.width)
        let remainingSpace = viewWidth - imageName.count * 350 - 60
        let spacing = CGFloat(remainingSpace / (imageName.count - 1))
        
        return spacing
    }
    
}
