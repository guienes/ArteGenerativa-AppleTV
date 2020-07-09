//
//  FirstViewController.swift
//  TestingAppleTV
//
//  Created by Guilherme Enes on 06/07/20.
//  Copyright © 2020 Guilherme Enes. All rights reserved.
//

import UIKit

class GaleryViewController: UIViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let defaultSize = CGSize(width: 458, height: 458)
    
    let focusSize = CGSize(width: 510, height: 510)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        //      collectionView.isScrollEnabled = false
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GaleriaCell", for: indexPath) as? GaleryCell {
            
            
            if cell.gestureRecognizers?.count == nil {
                let tap = UITapGestureRecognizer(target: self, action: "tapped:")
                tap.allowedPressTypes = [NSNumber(integerLiteral: UIPress.PressType.menu.rawValue)]
                cell.addGestureRecognizer(tap)
            }
            return cell
        } else {
            return GaleryCell()
        }
    }
    
    func tapped(gesture: UITapGestureRecognizer) {
        if let cell = gesture.view as? GaleryCell {
            //could load next view
            print("Reconhecido o toque")
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        if let prev = context.previouslyFocusedView as? GaleryCell {
            UIView.animate(withDuration: 0.1) {
                prev.galleryImg.frame.size = self.defaultSize
            }
        }
        
        if let next = context.nextFocusedView as? GaleryCell {
            
            UIView.animate(withDuration: 0.1) {
                next.galleryImg.frame.size = self.focusSize
            }
        }
    }
}

extension GaleryViewController: UIScrollViewDelegate, UICollectionViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
}
