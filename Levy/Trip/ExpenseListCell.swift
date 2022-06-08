//
//  ExpenseListCell.swift
//  Levy
//
//  Created by Praveenraj T on 08/04/22.
//

import UIKit

class ExpenseListCell: UITableViewCell {
    static let identifier = "ExpenseListCell"
    
    private lazy var containerView : UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = .tertiarySystemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowOpacity = 0.2
        view.layer.masksToBounds = false
        return view
    }()
    
    private lazy var expenseNameLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.setContentCompressionResistancePriority(UILayoutPriority(752), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(752), for: .vertical)
        label.setContentHuggingPriority(UILayoutPriority(252), for: .vertical)
        label.setContentHuggingPriority(UILayoutPriority(252), for: .horizontal)
        return label
    }()
    
    private lazy var dateView:UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        label.textColor = UIColor.secondaryLabel
        label.clipsToBounds = true
        label.setContentHuggingPriority(UILayoutPriority(255), for: .vertical)
        label.textAlignment = .left
        label.setContentCompressionResistancePriority(UILayoutPriority(752), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(255), for: .horizontal)
        
        
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var paidByLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.secondaryLabel
        
        return label
    }()
    
    private lazy var myshareLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.setContentCompressionResistancePriority(UILayoutPriority(753), for: .horizontal)
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
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        backgroundColor = .secondarySystemBackground
        selectionStyle = .none
        containerView.layer.shadowColor = UIColor.black.cgColor
        //dateView.layer.shadowColor = myShadowColor
        
        contentView.addSubview(containerView)
        containerView.addSubview(dateView)
        containerView.addSubview(expenseNameLabel)
        containerView.addSubview(paidByLabel)
        containerView.addSubview(totalAmountLabel)
        containerView.addSubview(myshareLabel)

        
        configureContainerView()
        configureExpenseNameLabel()
        configureMyShareLabel()
        configureDateView()
        configurePaidByLabel()
        configureTotalAmountLable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        expenseNameLabel.text   = nil
        myshareLabel.text       = nil
        dateView.text           = nil
        paidByLabel.text        = nil
        totalAmountLabel.text   = nil
        myshareLabel.textColor = .label
    }
    
    private func configureContainerView(){

        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,constant: 5),
            containerView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor,constant: -5),
            containerView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor,constant: 5),
            containerView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor,constant: -5)
        ])
    }
    
    private func configureExpenseNameLabel(){
        
        expenseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        let centerConstraint = expenseNameLabel.centerYAnchor.constraint(equalTo: myshareLabel.centerYAnchor)
        centerConstraint.priority = UILayoutPriority(990)
        NSLayoutConstraint.activate([
            centerConstraint,
            expenseNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 2),
           
            expenseNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 10),
            ])
    }
    
    private func configureMyShareLabel(){
        
        myshareLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            myshareLabel.centerYAnchor.constraint(equalTo: expenseNameLabel.centerYAnchor),
            myshareLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2),
            myshareLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -10),
            myshareLabel.leadingAnchor.constraint(equalTo: expenseNameLabel.trailingAnchor, constant: 10)
        ])
    }
    
    private func configureDateView(){
        dateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 10),
            dateView.topAnchor.constraint(equalTo: expenseNameLabel.bottomAnchor,constant: 5),
            dateView.trailingAnchor.constraint(lessThanOrEqualTo:containerView.trailingAnchor,constant: -10)
        ])
    }
    
    private func configurePaidByLabel(){
        
        paidByLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            paidByLabel.topAnchor.constraint(equalTo: dateView.bottomAnchor, constant: 5),
            paidByLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 10),
            paidByLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            //paidByLabel.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, multiplier: 1/3)
        ])
    }
    
    private func configureTotalAmountLable(){
        totalAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalAmountLabel.centerYAnchor.constraint(equalTo: paidByLabel.centerYAnchor),
            totalAmountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -10),
            totalAmountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: paidByLabel.trailingAnchor, constant: 10),
            totalAmountLabel.topAnchor.constraint(equalTo: dateView.bottomAnchor,constant: 5),
            totalAmountLabel.bottomAnchor.constraint(equalTo: paidByLabel.bottomAnchor)
        ])
    }
    
}

extension ExpenseListCell{
    func setExpenseNameLabel(with value:String){
        expenseNameLabel.text = value
    }
    func setDateViewLabel(with value:String){
        dateView.text = value
    }
    func setPaidByLabel(with value:String){
        paidByLabel.text = "Paid-by : " + value
    }
    func setMyShareLabel(with value:Double){
        myshareLabel.setNumericValue(value: value)
    }
    func setTotalAmountLabel(with value:Double){
        let formatter = currencyFormatter()
        guard let formattedAmount =  formatter.string(from: value as NSNumber) else{
            totalAmountLabel.text = "Total : 0"
            return
        }
        totalAmountLabel.text = "Total : \(formattedAmount)"
    }
}


