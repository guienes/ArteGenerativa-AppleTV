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

    @IBAction func goToMainScreenBtn(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
                defaults.set(true, forKey: "hasViewedWalkthrough")
                dismiss(animated: true, completion: nil)
    }
}
