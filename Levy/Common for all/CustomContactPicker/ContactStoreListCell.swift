//
//  cell.swift
//  customContactPIcker
//
//  Created by Praveenraj T on 19/04/22.
//

import Foundation
import UIKit

class ContactStoreListCell:UITableViewCell{
    static let identifier = "FriendsListTableViewCell"
    let containerView:UIView = {
        let containerView = UIView()
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 10
        containerView.backgroundColor = .systemGroupedBackground
        containerView.alpha = 1

        containerView.layer.masksToBounds = false
        
        return containerView
    }()
    
    let friendNameLabel:UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.numberOfLines = 0
        label.setContentHuggingPriority(UILayoutPriority(255), for: .vertical)
        return label
    }()
    
    let phoneNumberLabel:UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.numberOfLines = 0
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        clipsToBounds = true
       
        configureContainerView()
        configureFriendNameLabel()
        configurePhonenumberLabel()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContainerView(){
        contentView.addSubview(containerView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,constant: 5),
            containerView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor,constant: -5),
            containerView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor,constant: 5),
            containerView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor,constant: -5)
        ])
    }
    
    func configureFriendNameLabel(){
        containerView.addSubview(friendNameLabel)
        
        friendNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        friendNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -5).isActive = true
        friendNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 5).isActive = true
        friendNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5).isActive = true
        
    }
    
    func configurePhonenumberLabel(){
        containerView.addSubview(phoneNumberLabel)
        phoneNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberLabel.textColor = myThemeColor
        
        phoneNumberLabel.topAnchor.constraint(equalTo: friendNameLabel.bottomAnchor,constant: 10).isActive = true
        phoneNumberLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 5).isActive = true
        phoneNumberLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -5).isActive = true
        phoneNumberLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5).isActive = true
        
    }
    
    override func prepareForReuse() {
        accessoryType = .none
        friendNameLabel.text = nil
        phoneNumberLabel.text = nil
    }
    
}
