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
            self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
