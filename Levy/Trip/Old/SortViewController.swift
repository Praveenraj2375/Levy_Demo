//
//  SortVieController.swift
//  Levy
//
//  Created by Praveenraj T on 09/04/22.
//

import UIKit

//protocol SortTripListDelegate:AnyObject{
//    func updateSortKey(key:String)
//}
//protocol UpdateViewTransparencyDelegate:AnyObject{
//    func updateAlpha()
//}

class SortViewControllerOld: UIViewController {
    static let dateAse = "DateASC"
    static let dateDesc = "DateDESC"
    static let nameAse = "NameASC"
    static let nameDesc = "NameDESC"
    static let amountAsc = "AmountASC"
    static let amountDesc = "AmountDESC"
    
    weak var sortTripListDelegate:SortTripListDelegate?
    weak var updateViewTransparencyDelegate:UpdateViewTransparencyDelegate?
    lazy var dateNameLabel:UILabel = {
        let label = UILabel()
        label.text = "Date"
        return label
    }()
    
    lazy var dateSegmentButton:UISegmentedControl = {
        let items = ["ASC","DESC"]
        let button = UISegmentedControl(items: items)
        button.isMomentary = true
        button.addTarget(self, action: #selector(segmentDidTapped(_:)), for: .valueChanged)
        button.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        
        return button
        
    }()
    
    let nameLabel:UILabel = {
        let label = UILabel()
        label.text = "Name"
        return label
    }()
    
    lazy var nameSegmentButton:UISegmentedControl = {
        let items = ["ASC","DESC"]
        let button = UISegmentedControl(items: items)
        button.isMomentary = true
        button.addTarget(self, action: #selector(segmentDidTapped(_:)), for: .valueChanged)

        return button
    }()
    
    let amountLabel:UILabel = {
        let label = UILabel()
        label.text = "Amount"
        return label
    }()
    
    lazy var amountSegmentButton:UISegmentedControl = {
        let items = ["ASC","DESC"]
        let button = UISegmentedControl(items: items)
        button.isMomentary = true
        button.addTarget(self, action: #selector(segmentDidTapped(_:)), for: .valueChanged)
        return button
    }()
    
    lazy var nameLabelTopAnchor = nameLabel.topAnchor.constraint(equalTo: dateSegmentButton.bottomAnchor, constant: 20)
    lazy var nameLabelUpdatedTopAnchor = nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
    lazy var nameSegmentTopAnchor = nameSegmentButton.topAnchor.constraint(equalTo: dateSegmentButton.bottomAnchor, constant: 10)
    lazy var nameSegmentUpdatedTopAnchor = nameSegmentButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
    
    var preSelectedOrder = String()
    
    init(selectedKey:String){
        super.init(nibName: nil, bundle: nil)
        preSelectedOrder = selectedKey
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tertiarySystemBackground
        
        configureNameLabel()
        configureNameSegmentButton()
        configureAmountLabel()
        configureAmountSegmentButton()
        selectCurrentSortType()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(willCloseSortViewcontroller))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        willCloseSortViewcontroller()
    }
    
    @objc func willCloseSortViewcontroller(){
        updateViewTransparencyDelegate?.updateAlpha()
        dismiss(animated: true)
    }

    func selectCurrentSortType(){
        switch preSelectedOrder{
        case SortViewController.nameAse,SortViewController.nameDesc :selectNameSort()
        case SortViewController.dateAse , SortViewController.dateDesc : selectDateSort()
        case SortViewController.amountAsc , SortViewController.amountDesc : selectAmountSort()
            
        default : selectDateSort()
        }
    }
    
    func selectNameSort(){
        nameSegmentButton.isMomentary = false
        if preSelectedOrder == SortViewController.nameAse{
            nameSegmentButton.selectedSegmentIndex = 0
        }else{
            nameSegmentButton.selectedSegmentIndex = 1
        }
    }
    
    func selectDateSort(){
        dateSegmentButton.isMomentary = false
        if preSelectedOrder == SortViewController.dateAse{
            dateSegmentButton.selectedSegmentIndex = 0
        }else{
            dateSegmentButton.selectedSegmentIndex = 1
        }
    }
    
    func selectAmountSort(){
        amountSegmentButton.isMomentary = false
        if preSelectedOrder == SortViewController.amountAsc{
            amountSegmentButton.selectedSegmentIndex = 0
        }else{
            amountSegmentButton.selectedSegmentIndex = 1
        }
    }
    
    @objc func segmentDidTapped(_ button:UISegmentedControl){
        var key = String()
        if button == nameSegmentButton{
            switch nameSegmentButton.selectedSegmentIndex{
            case 0: key = SortViewController.nameAse
            case 1: key = SortViewController.nameDesc
            
            default:
                key = SortViewController.nameAse
            }
        }else if button == dateSegmentButton{
            switch dateSegmentButton.selectedSegmentIndex{
            case 0: key = SortViewController.dateAse
            case 1: key = SortViewController.dateDesc
            
            default:
                key = SortViewController.dateDesc
            }
        }else if button == amountSegmentButton{
            switch amountSegmentButton.selectedSegmentIndex{
            case 0: key = SortViewController.amountAsc
            case 1: key = SortViewController.amountDesc
            
            default:
                key = SortViewController.amountDesc
            }
        }
        updateViewTransparencyDelegate?.updateAlpha()
        sortTripListDelegate?.updateSortKey(key: key)

        dismiss(animated: true)
    }
    
    func configureDateLabel(){
        view.addSubview(dateNameLabel)
        dateNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dateNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        ])
    }
    
    func configureDateSegmentButton(){
        view.addSubview(dateSegmentButton)
        dateSegmentButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateSegmentButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            dateSegmentButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            dateSegmentButton.leadingAnchor.constraint(greaterThanOrEqualTo: dateNameLabel.trailingAnchor, constant: 10)
        ])
    }

    func configureNameLabel(){
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        ])
    }
    func configureAmountLabel(){
        view.addSubview(amountLabel)
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            amountLabel.topAnchor.constraint(equalTo: nameSegmentButton.bottomAnchor, constant: 20),
            amountLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        ])
    }
    
    func configureNameSegmentButton(){
        view.addSubview(nameSegmentButton)
        nameSegmentButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameSegmentButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            nameSegmentButton.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 10)
        ])
    }
    
    
    func configureAmountSegmentButton(){
        view.addSubview(amountSegmentButton)
        amountSegmentButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            amountSegmentButton.topAnchor.constraint(equalTo: nameSegmentButton.bottomAnchor,constant: 10),
            amountSegmentButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            amountSegmentButton.leadingAnchor.constraint(greaterThanOrEqualTo: amountLabel.trailingAnchor, constant: 10)
        ])
    }
}
