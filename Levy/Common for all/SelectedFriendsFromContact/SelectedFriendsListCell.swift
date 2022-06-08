//
//  SelectedFriendsListCell.swift
//  Levy
//
//  Created by Praveenraj T on 04/04/22.
//

import UIKit

protocol RemoveFriendsFromSelectedFreindsDelegate:AnyObject{
    func removeFriend(at cell:UITableViewCell)
}

class SelectedFriendsListCell: UITableViewCell {
    static let identifier = "SelectedFriendsListCell"
    weak var removeFriendsFromSelectedFreindsDelegate:RemoveFriendsFromSelectedFreindsDelegate?
    private let containerView :UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemBackground
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        
        return view
    }()
    
    private let nameLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.setContentHuggingPriority(UILayoutPriority(249), for: .vertical)
        return label
    }()
    
    private let phoneNumberLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    let deleteButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "person.crop.circle.badge.minus"), for: .normal)
        button.imageView?.contentMode = .scaleToFill
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        backgroundColor = .secondarySystemBackground
        
        configureContainerView()
        configureNameLabel()
        configurePhoneNumberLabel()
        configureDeleteButton()
    }
    
    override func prepareForReuse() {
        accessoryType = .none
        nameLabel.text = nil
        phoneNumberLabel.text = nil
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
    
    private func configureNameLabel(){
        containerView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor,constant: 5),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor,constant: -5)
            
        ])
    }
    
    private func configurePhoneNumberLabel(){
        containerView.addSubview(phoneNumberLabel)
        phoneNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            phoneNumberLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,constant: 7),
            phoneNumberLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor,constant: 5),
            phoneNumberLabel.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            phoneNumberLabel.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor,constant: -5)
        ])
    }
    
    private func configureDeleteButton(){
        containerView.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 5),
            deleteButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: 5),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -5),
            deleteButton.widthAnchor.constraint(equalToConstant: 44)
        ])
        deleteButton.addTarget(self, action: #selector(deleteButtonDidTapped), for: .touchUpInside)
        
    }
        
    @objc  func deleteButtonDidTapped(){
        removeFriendsFromSelectedFreindsDelegate?.removeFriend(at: self)
    }
}

extension SelectedFriendsListCell{
    func setNameLable(with value:String){
        nameLabel.text = value
    }
    
    func setPhoneNumberLabel(with value:String){
        phoneNumberLabel.text = value
    }
}
