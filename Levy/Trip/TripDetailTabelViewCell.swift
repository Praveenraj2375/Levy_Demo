//
//  AboutTableViewCell.swift
//  Levy
//
//  Created by Praveenraj T on 12/03/22.
//

import UIKit

class AboutTableViewCell: UITableViewCell {
    static let identifier = "AboutTableViewCell"
    private lazy var containerView : UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .tertiarySystemBackground
        return view
    }()
    
    lazy var detailNameLable:UITextView = {
        let label = UITextView()
        label.backgroundColor = secondaryCustomColor
        label.textAlignment = .right
        label.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        label.font = UIFont.systemFont(ofSize: 15)
        
        return label
    }()
    
    private lazy var detailValueLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
   
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .tertiarySystemBackground
        backgroundColor = .tertiarySystemBackground
        selectionStyle = .none
        configureContainerView()
        configureDetailNameLable()
        configureDetailValueLabel()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        detailValueLabel.textColor = .secondaryLabel
        detailValueLabel.text = nil
        detailNameLable.text = nil
        accessoryType = .none
    }
    
    private func configureContainerView(){
        contentView.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureDetailNameLable(){
        containerView.addSubview(detailNameLable)
        detailNameLable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailNameLable.topAnchor.constraint(equalTo: containerView.topAnchor),
            detailNameLable.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 10),
            detailNameLable.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/3),
            detailNameLable.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            
        ])
    }
    
    private func configureDetailValueLabel(){
        containerView.addSubview(detailValueLabel)
        detailValueLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailValueLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            detailValueLabel.leadingAnchor.constraint(equalTo: detailNameLable.trailingAnchor,constant: 10),
            detailValueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -0),
            detailValueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    func setDetailNameLabel(with value:String){
        detailNameLable.text = value
    }
    
    func setDetailValueLabel(with value:String){
        detailValueLabel.text = value
    }
}
