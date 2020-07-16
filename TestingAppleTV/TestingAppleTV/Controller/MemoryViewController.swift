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
    
    @IBOutlet weak var savedPhotosLBL: UILabel!
    
    let addMemoriesLBL = UILabel()
    
    var context: NSManagedObjectContext?
    var memories = [Memory]()
    
    var saveMemory = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLBL()
        
        self.view.addSubview(addMemoriesLBL)
        
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
        
        if memories.count > 0 {
            savedPhotosLBL.isHidden = false
            addMemoriesLBL.isHidden = true
        } else {
            addMemoriesLBL.isHidden = false
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoriaCell", for: indexPath) as? MemoryCell {
            
            guard let data = memories[indexPath.row].image else {
                return MemoryCell()
            }
            
            saveMemory = data
            
            cell.memoryImg.image = UIImage(data: data)
            
            
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
        
        guard let data = memories[indexPath.row].image else {
            return
        }
        
        saveMemory = data
        
        performSegue(withIdentifier: "MemoryPhotoShow", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let showImageVC = segue.destination as? MemoryPhotosShow else { return }
        
        print(saveMemory)
        showImageVC.imageToPresent = UIImage(data: saveMemory) ?? UIImage()
        
    }
    
    
    func setLBL() {
        
        addMemoriesLBL.isHidden = true
        
        addMemoriesLBL.frame = CGRect(x: self.view.frame.width/3.7, y: self.view.frame.height/2.8, width: 900, height: 200)
        
        addMemoriesLBL.font = addMemoriesLBL.font.withSize(60)
        
        addMemoriesLBL.textAlignment = .center
        
        addMemoriesLBL.text = "Algo motivador será escrito aqui!"
    }
    
}

