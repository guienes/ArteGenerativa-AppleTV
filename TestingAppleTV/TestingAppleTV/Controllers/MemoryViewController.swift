//
//  SecondViewController.swift
//  TestingAppleTV
//
//  Created by Guilherme Enes on 06/07/20.
//  Copyright © 2020 Guilherme Enes. All rights reserved.
//

import UIKit
import CoreData

class MemoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let defaultSize = CGSize(width: 400, height: 400)
    let focusSize = CGSize(width: 440, height: 440)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var context: NSManagedObjectContext?
    var memories = [Memory]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        do{
            memories = try context!.fetch(Memory.fetchRequest())
        } catch {
            print("Erro ao carregar memórias")
            return
        }
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoriaCell", for: indexPath) as? MemoryCell {
            
            if cell.gestureRecognizers?.count == nil {
                let tap = UITapGestureRecognizer(target: self, action: "tapped:")
                tap.allowedPressTypes = [NSNumber(integerLiteral: UIPress.PressType.menu.rawValue)]
                cell.addGestureRecognizer(tap)
            }
            
            guard let data = memories[indexPath.row].image else {
                return MemoryCell()
            }
            cell.memoryImg.image = UIImage(data: data)
            
            return cell
            
        } else {
            return MemoryCell()
        }
    }
    
    
    func tapped(gesture: UITapGestureRecognizer) {
        if let cell = gesture.view as? MemoryCell {
            //could load next view
            print("Reconhecido o toque")
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memories.count
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        if let prev = context.previouslyFocusedView as? MemoryCell {
            UIView.animate(withDuration: 0.1) {
                prev.memoryImg.frame.size = self.defaultSize
            }
        }
        
        if let next = context.nextFocusedView as? MemoryCell {
            
            UIView.animate(withDuration: 0.1) {
                next.memoryImg.frame.size = self.focusSize
            }
        }
    }
    
}

