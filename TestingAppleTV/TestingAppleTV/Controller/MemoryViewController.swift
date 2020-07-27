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
    @IBOutlet weak var noMemoriesLabel: UILabel!
    @IBOutlet weak var savedPhotosLBL: UILabel!
    
    var context: NSManagedObjectContext?
    var memories = [Memory]()
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        self.collectionView.addGestureRecognizer(longPress)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            memories = try context!.fetch(Memory.fetchRequest())
        } catch {
            print("Erro ao carregar memórias")
            return
        }
        
        collectionView.reloadData()
        noMemoriesLabel.isHidden = memories.count > 0
        savedPhotosLBL.isHidden = !noMemoriesLabel.isHidden
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        print("longpressed")
        guard let indexPath = collectionView.indexPathForItem(at: sender.location(in: self.collectionView)) else { return }
        presentPopUp(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoriaCell", for: indexPath) as? MemoryCell {
            
            guard let data = memories[indexPath.row].image else {
                return MemoryCell()
            }
            cell.memoryImg.image = UIImage(data: data)
            cell.memoryImg.adjustsImageWhenAncestorFocused = true
            cell.memoryImg.layer.cornerRadius = cell.memoryImg.frame.height / 32
            
            cell.layer.shadowOpacity = 200
            cell.layer.shadowRadius = 30
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 10, height: 10)
            
            return cell
            
        } else {
            return MemoryCell()
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        
        if memories.count == 0 {
            noMemoriesLabel.isHidden = false
            savedPhotosLBL.isHidden = true
        }
        performSegue(withIdentifier: "MemoryPhotoShow", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let showImageVC = segue.destination as? MemoryPhotosShow else { return }
        showImageVC.memories = self.memories
        showImageVC.currentIndex = self.selectedIndex
    }
    
    func presentPopUp(for indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Excluir memória",
            message: "Você tem certeza de que deseja remover a foto das suas memórias?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .destructive, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            self.deleteItem(at: indexPath)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancelar", comment: "Default action"), style: .cancel, handler: { _ in
            NSLog("The \"Cancelar\" alert occured.")
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteItem(at indexPath: IndexPath) {
        let item = memories[indexPath.row]
        memories.remove(at: indexPath.row)
        context?.delete(item)
        collectionView.deleteItems(at: [indexPath])
        noMemoriesLabel.isHidden = memories.count > 0
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
}



