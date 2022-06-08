//
//  CollectionViewFooter.swift
//  Levy
//
//  Created by Praveenraj T on 21/04/22.
//

import Foundation
import UIKit

class CollectionViewFooter: UICollectionReusableView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 22)
        
        return label
    }()
    
    let refreshButton:UIButton = {
        let button = UIButton()
        button.setTitle("Refresh", for: .normal)
        button.backgroundColor = UIColor(named: "myTheme")
        button.setTitleColor(.systemBackground, for: .normal)
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.tintColor = .systemBackground
        button.setContentHuggingPriority(UILayoutPriority(255), for: .horizontal)
        if #available(iOS 15.0, *){
            var buttonConfig = UIButton.Configuration.borderedTinted()
            buttonConfig.imagePadding = 10
            button.configuration = buttonConfig
        }else{
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureTitleLabel()
        configureRefreshButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureTitleLabel()
        configureRefreshButton()
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    private func configureTitleLabel() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 5),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            titleLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 5),
           
        ])
    }
    
    func configureRefreshButton(){
        addSubview(refreshButton)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            refreshButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor,constant: 10),
            refreshButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -5),
            refreshButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            refreshButton.heightAnchor.constraint(equalToConstant: 40),
            refreshButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }

}
