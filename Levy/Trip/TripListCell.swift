//
//  TripListCell.swift
//  Levy
//
//  Created by Praveenraj T on 09/03/22.
//

import UIKit
import Foundation

protocol CellDidSelectedDelegate{
    func cellDidselected()
}
class TripListCell: UITableViewCell {
static let identifier = "tripCell"
     lazy var containerView : UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        view.layer.cornerRadius = 100
        view.backgroundColor = .tertiarySystemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowOpacity = 0.2
        view.layer.masksToBounds = false
        
        return view
    }()
    
    private lazy var dateView:UILabel = {
       let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.numberOfLines = 3
        label.backgroundColor = UIColor(named: "date")
        label.textAlignment = .center
        label.setContentCompressionResistancePriority(UILayoutPriority(752), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(255), for: .horizontal)
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var tripNameLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 20)
        
        return label
    }()
    
    private lazy var friendsCountLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    private lazy var myshareLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.setContentCompressionResistancePriority(UILayoutPriority(752), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(255), for: .horizontal)
        label.textAlignment = .right

        return label
    }()
    
    private lazy var totalAmountLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(UILayoutPriority(752), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(255), for: .horizontal)
        return label
    }()
    
    let gradientLayer = CAGradientLayer()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
//        contentView.clipsToBounds =  true
//        contentView.layer.cornerRadius = 15
//        self.layer.cornerRadius = 15
//        clipsToBounds = true
        backgroundColor = .secondarySystemBackground

        
        contentView.addSubview(containerView)
        containerView.addSubview(dateView)
        containerView.addSubview(tripNameLabel)
        containerView.addSubview(friendsCountLabel)
        containerView.addSubview(totalAmountLabel)
        containerView.addSubview(myshareLabel)

        configureContainerView()
        configureDateView()
        configureMyShareLabel()
        configureTripNameLabel()
        configureMemberCount()
        configureTotalAmountLable()
        
        
    }
    
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setShadowPathForContainer(){

//        containerView.layer.shadowPath = CGPath(rect: containerView.bounds, transform: nil)
        
    }

    private func configureContainerView(){
         containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,constant: 10),
            containerView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -10),
            containerView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor,constant: 10),
            containerView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor,constant: -8)
        ])

        

    }
    
    private func configureTripNameLabel(){
        tripNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let centerConstraint = tripNameLabel.centerYAnchor.constraint(equalTo: myshareLabel.centerYAnchor)
        centerConstraint.priority = UILayoutPriority(997)
        NSLayoutConstraint.activate([
            tripNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 2),
            tripNameLabel.leadingAnchor.constraint(equalTo: dateView.trailingAnchor,constant: 10)
        ])
    }
    
    private func configureDateView(){
        dateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 3),
            dateView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 2),
            
            dateView.heightAnchor.constraint(equalToConstant: 65),
            dateView.widthAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func configureMemberCount(){
        friendsCountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            friendsCountLabel.topAnchor.constraint(equalTo: tripNameLabel.bottomAnchor, constant: 10),
            friendsCountLabel.leadingAnchor.constraint(equalTo: dateView.trailingAnchor,constant: 10),
            friendsCountLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            friendsCountLabel.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, multiplier: 1/3)
        ])
    }
    
    private func configureMyShareLabel(){
        myshareLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            myshareLabel.centerYAnchor.constraint(equalTo: tripNameLabel.centerYAnchor),
            myshareLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2),
            myshareLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -10),
            myshareLabel.bottomAnchor.constraint(lessThanOrEqualTo: totalAmountLabel.topAnchor, constant: -10),
            myshareLabel.leadingAnchor.constraint(equalTo: tripNameLabel.trailingAnchor, constant: 10)
        ])
    }
    
    private func configureTotalAmountLable(){
        totalAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalAmountLabel.centerYAnchor.constraint(equalTo: friendsCountLabel.centerYAnchor),
            totalAmountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -10),
            totalAmountLabel.leadingAnchor.constraint(equalTo: friendsCountLabel.trailingAnchor, constant: 10)
        ])
    }
    
    override func prepareForReuse() {
        totalAmountLabel.attributedText = nil
        tripNameLabel.text = nil
        dateView.text = nil
        friendsCountLabel.text = nil
        totalAmountLabel.text = nil
        containerView.layer.shadowPath = nil
    }
}

extension TripListCell{
    func setTripNameLable(with value:String){
        tripNameLabel.text = value
    }
    func setDateViewLable(with value:String){
        dateView.text = value
    }
    func setFriendsCountLabel(with value:UInt){
        if value == 0{
            friendsCountLabel.text = "No Friends"
        }
        else if value == 1{
            friendsCountLabel.text = "1 Friend"
        }
        else{
            friendsCountLabel.text = "\(value) Friends"
        }
        
    }
    func setMyShareLabel(with value:Double,totalExp:Double = 0){
        if totalExp == 0{
            myshareLabel.font = UIFont.boldSystemFont(ofSize:14)
            myshareLabel.textColor = .systemGreen
            myshareLabel.text = "No Expense\n added"
            return
        }else{
            myshareLabel.font = UIFont.boldSystemFont(ofSize: 20)
            myshareLabel.setNumericValue(value: value)
        }
    }
    func setTotalAmountLabel(with value:Double){
        if value > 0{
            let formatter = currencyFormatter()
            if let formattedAmount = formatter.string(from: value as NSNumber){
                totalAmountLabel.text = "Total : \(formattedAmount) "
            } else{
                totalAmountLabel.text = " "
            }
        }
        else{
            totalAmountLabel.text = " "
        }
        
    }
}
