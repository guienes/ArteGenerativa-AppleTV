//
//  DescriptionView.swift
//  TestingAppleTV
//
//  Created by Lia Kassardjian on 15/07/20.
//  Copyright © 2020 Guilherme Enes. All rights reserved.
//

import UIKit

class DescriptionView: UIView {
    
    lazy var descriptionText: UILabel = {
        let descriptionText = UILabel()
        descriptionText.font = UIFont.systemFont(ofSize: 31, weight: .medium)
        descriptionText.text = "Descrição"
        descriptionText.numberOfLines = 0
        descriptionText.textAlignment = .center
        descriptionText.translatesAutoresizingMaskIntoConstraints = false
        return descriptionText
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 0.75)
        layer.cornerRadius = 10
        layer.masksToBounds = true;
        addSubview(descriptionText)
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            descriptionText.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            descriptionText.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15),
            descriptionText.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            descriptionText.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15)
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
}
