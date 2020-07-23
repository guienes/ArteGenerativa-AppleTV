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
    var saveMemory = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        collectionView.delegate = self
        collectionView.dataSource = self
        
  
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


    func tapped(sender: UITapGestureRecognizer)
    {
        print("tapped")
    }

    func longPressed(sender: UILongPressGestureRecognizer)
    {
        print("longpressed")
    }
//      func setupTap() {
//          let shortPress = UITapGestureRecognizer()
//          let longPress = UILongPressGestureRecognizer(target:self, action: #selector(didTouchDown))
//
//
//
//        longPress.minimumPressDuration = 2
//        longPress.delaysTouchesBegan = true
//        longPress.delegate = self
//          view.addGestureRecognizer(longPress)
//
//        if shortPress.isEnabled == false {
//            longPress.isEnabled = true
//           longTap(sender: longPress)
//
//            } else {
//            shortPress.isEnabled = true
//            longPress.isEnabled = false
//            performSegue(withIdentifier: "MemoryPhotoShow", sender: self)
//        }
//      }
//      @objc func didTouchDown(gesture: UILongPressGestureRecognizer) {
//          if gesture.state == .began {
//            let showPopUp = PopUpViewController()
//                       showPopUp.modalTransitionStyle  =  .crossDissolve
//                       showPopUp.modalPresentationStyle = .overCurrentContext
//                       self.present(showPopUp, animated: true, completion: nil)
//
//          }
//      }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoriaCell", for: indexPath) as? MemoryCell {
            
            guard let data = memories[indexPath.row].image else {
                return MemoryCell()
            }
            print("toque reconhecido")
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
 
        if memories.count == 0 {
           noMemoriesLabel.isHidden = false
           savedPhotosLBL.isHidden = true
           }
        performSegue(withIdentifier: "MemoryPhotoShow", sender: self)
    }
    
// Aparece o Pop Up para remover a foto
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            // Aparentemente o .select não funciona (ao menos no simulador)
            if press.type == .playPause {
    let alert = UIAlertController(title: "Remover foto", message: "Você tem certeza de que deseja remover a foto das tuas memórias?", preferredStyle: .alert)
             
             alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
             NSLog("The \"OK\" alert occured.")
               
               self.removeCell()
                   }))
                 
                 alert.addAction(UIAlertAction(title: NSLocalizedString("Cancelar", comment: "Default action"), style: .cancel, handler: { _ in
                 NSLog("The \"Cancelar\" alert occured.")
             }))
             self.present(alert, animated: true, completion: nil)
             
            }
        }
    }

    // Está dando ruim
    func deleteMemory(at indexPath: IndexPath) {
        memories.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        print("memória removida")
    }
    
    func removeCell() {
        self.collectionView.performBatchUpdates({
            memories.popLast()
            self.collectionView.deleteItems(at: [IndexPath(item: memories.count - 1, section: 0)])
        }) { (competed) in
            print("Perform batch updates completed")
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let showImageVC = segue.destination as? MemoryPhotosShow else { return }
        
        print(saveMemory)
        showImageVC.imageToPresent = UIImage(data: saveMemory) ?? UIImage()
        
    }
    
    func deleteData() {
         guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

         let managedContext = appDelegate.persistentContainer.viewContext
         
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Memory")
         fetchRequest.predicate = NSPredicate(format: "memory = %@", "mem")
        
         do
         {
             let test = try managedContext.fetch(fetchRequest)
             
             let objectToDelete = test[0] as! NSManagedObject
             managedContext.delete(objectToDelete)
             
             do{
                 try managedContext.save()
             }
             catch
             {
                 print(error)
             }
             
         }
         catch
         {
             print(error)
         }
    }
}
    


