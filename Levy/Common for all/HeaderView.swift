//
//  HeaderView.swift
//  Levy
//
//  Created by Praveenraj T on 06/04/22.
//

import UIKit

class HeaderView: UITableViewHeaderFooterView {

    static let identifier = "header"
    
    let containerView :UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
        view.alpha = 1
        return view
    }()
    
    var titleLabel : UILabel = {
        var label = UILabel()
        label.textColor = .systemGray2
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        configureContainerView()
        configureTitleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureContainerView(){
        contentView.addSubview(containerView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 10),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor,constant:3),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -3)
        ])
    }
    
    private func configureTitleLabel(){
        containerView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor,constant: -5)
        ])
    }
    
    func setTitleLabel(with text:String){
        titleLabel.text = text
    }

}
