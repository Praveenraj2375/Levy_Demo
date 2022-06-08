//
//  ExpesencsDetailCell.swift
//  Levy
//
//  Created by Praveenraj T on 05/04/22.
//

import Foundation
import UIKit

protocol SettleupButtonDelegate:AnyObject{
    func settleupButtonDidTappd(at cell:UITableViewCell)
}

class ExpesenceDetailCell:UITableViewCell{
    static let identifier = "ExpesenceDetailCell"
    
    var settleupButtonDelegate:SettleupButtonDelegate?
    
    private let containerView :UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemBackground
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowOpacity = 0.2
        view.layer.masksToBounds = false
        return view
    }()
    
    private let titleLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let topRightLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    lazy var bottomLeftButton:UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(bottomLeftButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var settleUpButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = myThemeColor
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.setTitle("Settle-Up", for: .normal)
        button.addTarget(self, action: #selector(settleupButtonDidTapped), for: .touchUpInside)

        return button
    }()
    
    
    lazy var settleUpButtonHeightAnchor = settleUpButton.heightAnchor.constraint(equalToConstant: 40)
    lazy var settleUpButtonZeroHeight = settleUpButton.heightAnchor.constraint(equalToConstant: 0)
    lazy var topRightLabelCenterYAnchor = topRightLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
    
    lazy var bottomLeftButtonHeightAnchor = bottomLeftButton.heightAnchor.constraint(lessThanOrEqualToConstant: 40)
    lazy var bottomLeftButtonZeroHeight = bottomLeftButton.heightAnchor.constraint(equalToConstant: 0)
    
    lazy var titileLabelCenterYAnchor = titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        backgroundColor = .secondarySystemBackground
        
      
        configureContainerView()
        configureTitleLabel()
        configuretopRightLabel()
        configureSettleUpButton()
        configureBottomLeftButton()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        topRightLabel.text = nil
        bottomLeftButton.setTitle(nil, for: .normal)
        
    }
    
    func configureButtonContent(){
        bottomLeftButton.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        bottomLeftButton.setTitleColor(myThemeColor, for: .normal)
        bottomLeftButton.backgroundColor = .clear
        bottomLeftButton.tintColor = myThemeColor
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
    
    private func configureTitleLabel(){
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let top = titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8)
        top.priority = UILayoutPriority(990)
        NSLayoutConstraint.activate([
            top,
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor,constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.centerXAnchor),
         
        ])
    }
    
    private func configuretopRightLabel(){
        containerView.addSubview(topRightLabel)
        topRightLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let top = topRightLabel.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 5)
        top.priority = UILayoutPriority(250)
        NSLayoutConstraint.activate([
            top,
            topRightLabel.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor,constant: 5),
            topRightLabel.leadingAnchor.constraint(equalTo: containerView.centerXAnchor),
            topRightLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    func configureSettleUpButton(){
        containerView.addSubview(settleUpButton)
        settleUpButton.translatesAutoresizingMaskIntoConstraints = false
       
        
        NSLayoutConstraint.activate([
            settleUpButton.leadingAnchor.constraint(equalTo: containerView.centerXAnchor),
            settleUpButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -5),
            settleUpButton.bottomAnchor.constraint(lessThanOrEqualTo:  containerView.bottomAnchor,constant: -5),
            settleUpButton.topAnchor.constraint(greaterThanOrEqualTo: topRightLabel.bottomAnchor, constant: 5)
        ])
    }
    
    func configureBottomLeftButton(){
        containerView.addSubview(bottomLeftButton)
        bottomLeftButton.translatesAutoresizingMaskIntoConstraints = false
        
        let bottom = bottomLeftButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5)
        bottom.priority = UILayoutPriority(998)
        NSLayoutConstraint.activate([
            bottomLeftButton.topAnchor.constraint(greaterThanOrEqualTo:  titleLabel.bottomAnchor,constant: 8),
            bottomLeftButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 8),
            bottomLeftButton.trailingAnchor.constraint(lessThanOrEqualTo: containerView.centerXAnchor),
            bottomLeftButton.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8),
            bottom
            //bottomLeftButtonHeightAnchor
            
        ])
    }
    
    func updateUIForAllSettledState(){
        settleUpButton.isHidden = true
        settleUpButton.isEnabled = false
        settleUpButtonHeightAnchor.isActive = false
        settleUpButtonZeroHeight.isActive = true
        topRightLabelCenterYAnchor.isActive = true
    }
    
    func updateUIForSettleState(){
        settleUpButton.isHidden = false
        settleUpButton.isEnabled = true
        settleUpButtonZeroHeight.isActive = false
        settleUpButtonHeightAnchor.isActive = true
        topRightLabelCenterYAnchor.isActive = false

    }
    
    func setTitlelabel(with value:String){
        titleLabel.text = value
    }
    
    func setTopRightLable(with value:Double){
        topRightLabel.setNumericValue(value: value)
    }
}

extension ExpesenceDetailCell{
    @objc func bottomLeftButtonDidTapped(){
        guard let number = bottomLeftButton.title(for: .normal)?.replacingOccurrences(of: " ", with: "") else{
            print("***Error-while unwrapping")
            return
        }
        let phoneNo = "tel://\(number)"
        guard let url = URL(string: phoneNo) else {
            print("url error")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url,options: [:])
            
        }
        else{
            print("call error")
        }
    }
    
    @objc func settleupButtonDidTapped(){
        settleupButtonDelegate?.settleupButtonDidTappd(at: self)
    }
}
