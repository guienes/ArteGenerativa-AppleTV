//
//  OnboardingViewController.swift
//  TestingAppleTV
//
//  Created by Tamara Erlij on 08/07/20.
//  Copyright © 2020 Guilherme Enes. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func setupTap() {
        let touchDown = UILongPressGestureRecognizer(target:self, action: #selector(didTouchDown))
        touchDown.minimumPressDuration = 0
        view.addGestureRecognizer(touchDown)
    }

    @objc func didTouchDown(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
             let defaults = UserDefaults.standard
                          defaults.set(true, forKey: "hasViewedWalkthrough")
                          dismiss(animated: true, completion: nil)
        }
    }

}
