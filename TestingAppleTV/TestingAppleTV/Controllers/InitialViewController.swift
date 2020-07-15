//
//  InitialViewController.swift
//  TestingAppleTV
//
//  Created by Tamara Erlij on 09/07/20.
//  Copyright © 2020 Guilherme Enes. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTap()
    }
    
    func setupTap() {
        let defaults = UserDefaults.standard
        let touchDown = UILongPressGestureRecognizer(target:self, action: #selector(didTouchDown))
        defaults.set(true, forKey: "hasViewedWalkthrough");         touchDown.minimumPressDuration = 0
        dismiss(animated: true, completion: nil);                view.addGestureRecognizer(touchDown)
    }
    
    @objc func didTouchDown(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            performSegue(withIdentifier: "goToMainScreen", sender: self)
        }
    }
}
