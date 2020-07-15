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
        descriptionText.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        descriptionText.text = "Descrição"
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
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        layer.cornerRadius = 5
        layer.masksToBounds = true;
        addSubview(descriptionText)
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            descriptionText.topAnchor.constraint(equalTo: self.topAnchor),
            descriptionText.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            descriptionText.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            descriptionText.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
}
