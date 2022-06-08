//
//  ViewForEmptyTableview.swift
//  Levy
//
//  Created by Praveenraj T on 08/04/22.
//

import UIKit

class ViewForEmptyTableview: UIView {
    
    
    let primaryLabel:UILabel = {
        let label = UILabel()
        label.textColor  = .tertiaryLabel
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    let secondaryLabel:UILabel = {
        let label = UILabel()
        label.textColor  = .tertiaryLabel
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    let actionButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = myThemeColor
        
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        return button
    }()
    
    init(){
        super.init(frame: .zero)
        backgroundColor = .systemGray6
        configureLabel()
        configureSecondaryLabel()
        configureActionButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel(){
        self.addSubview(primaryLabel)
        
        NSLayoutConstraint.activate([
            primaryLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            primaryLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            primaryLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }
    
    func configureSecondaryLabel(){
        self.addSubview(secondaryLabel)
        
        NSLayoutConstraint.activate([
            secondaryLabel.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor,constant: 5),
            secondaryLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            secondaryLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30)
        ])
    }
    
    func configureActionButton(){
        self.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: secondaryLabel.bottomAnchor,constant: 10),
            actionButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            actionButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30)
        ])
    }
}

