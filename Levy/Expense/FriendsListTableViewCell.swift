//
//  FriendsListTableViewCell.swift
//  Levy
//
//  Created by Praveenraj T on 28/04/22.
//

import Foundation
import UIKit

class FriendsListTableViewCell:UITableViewCell{
    static let identifier = "FriendsListTableViewCell"
    private let containerView:UIView = {
        let containerView = UIView()
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 10
        containerView.backgroundColor = .tertiarySystemFill
        containerView.alpha = 1
        containerView.layer.masksToBounds = false
        
        return containerView
    }()
    
    private let friendNameLabel:UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.numberOfLines = 0
        label.setContentHuggingPriority(UILayoutPriority(255), for: .vertical)
        return label
    }()
    
    private let phoneNumberLabel:UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.numberOfLines = 0
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .systemBackground
        clipsToBounds = true
        configureContainerView()
        configureFriendNameLabel()
        configurePhonenumberLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureContainerView(){
        contentView.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,constant: 5),
            containerView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor,constant: -5),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 5),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -5)
        ])
    }
    
    private func configureFriendNameLabel(){
        containerView.addSubview(friendNameLabel)
        
        friendNameLabel.translatesAutoresizingMaskIntoConstraints = false
        //friendNameLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        friendNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -5).isActive = true
        friendNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 5).isActive = true
        friendNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5).isActive = true
        
    }
    
    private func configurePhonenumberLabel(){
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
    
    func setFriendNameLabel(with value:String){
        friendNameLabel.text = value
    }
    func setPhoneNumberLabel(with value:String,textColor:UIColor = UIColor(named: "myTheme") ?? .label){
        phoneNumberLabel.text = value
        phoneNumberLabel.textColor = textColor
    }
    
}
