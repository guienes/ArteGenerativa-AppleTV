//
//  PopUpViewController.swift
//  TestingAppleTV
//
//  Created by Tamara Erlij on 22/07/20.
//  Copyright © 2020 Guilherme Enes. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

    var memory = MemoryViewController()
    


    override func viewDidLoad() {
        super.viewDidLoad()
      
    }

    @IBAction func deleteButton(_ sender: Any) {
//        let closeTabAction = UIPreviewAction(title: "Close Tab", style: .destructive, handler: { (action, viewController) in
         
            
//        })
        
            self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
//        let closeTabCancelAction = UIPreviewAction(title: "Cancel", style: .default, handler: { (action, viewController) in
//
                //cancel action, don't need anything here
        //    })
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
