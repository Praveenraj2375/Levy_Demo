//
//  TripDetailedViewController.swift
//  Levy
//
//  Created by Praveenraj T on 11/03/22.
//

import UIKit
import Contacts
import ContactsUI



protocol TripDetailVCRefresherDelegate:AnyObject{
    func refreshData()
}

protocol FriendsListUpdationDelegate:AnyObject{
    func updateFriendsList()
}

class TripDetailedViewController: UIViewController {
    
    
    weak var tripListVCRefresherDelegate   : TripListVCRefresherDelegate?
    weak var groupDetailVCRefersherDelegate: GroupDetailVCRefersherDelegate?
    
    var addFriendButtonDelegate:AddFriendButtonDelegate?
    var addExpenseButtonDelegate:AddExpenseButtonDelegate?
    lazy var tripDetailTableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .secondarySystemBackground
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()
    
    
    
    lazy var stackViewForAddButton:UIStackView = {
        let stackview = UIStackView()
        stackview.distribution = .fillEqually
        stackview.axis = .horizontal
        stackview.alignment = .center
        stackview.spacing = 50
        
        return stackview
    }()
    
    
    lazy var addFriendButton:UIButton = {
        let button = UIButton(type: .contactAdd)
        button.setTitle("Add Friends", for: .normal)
        
        button.setImage(UIImage(systemName: "person.crop.circle.badge.plus"), for: .normal)
        button.addTarget(addFriendButtonDelegate, action: #selector(addFriendButtonDelegate?.addFriendButtonDidTapped), for: .touchUpInside)
        if #available(iOS 15.0, *){
            var config = UIButton.Configuration.plain()
            config.imagePadding = 5
            button.configuration = config
        }else{
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        }
        return button
    }()
    
    //must not private
    lazy var addExpenseButton:UIButton = {
        let button = UIButton(type: .contactAdd)
        button.setTitle("Add Expense", for: .normal)
        

        if #available(iOS 14.0, *){
            button.setImage(UIImage(systemName: "wallet.pass"), for: .normal)
            button.role = .primary
        }else{
            button.setImage(UIImage(systemName: "dollar"), for: .normal)
        }
        
        if #available(iOS 15.0, *){
            var config = UIButton.Configuration.plain()
            config.imagePadding = 5
            button.configuration = config
            
        }else{
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        }
        
        button.backgroundColor = .clear
        button.addTarget(addExpenseButtonDelegate, action: #selector(addExpenseButtonDelegate?.addExpenseButtonDidTapped), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        return button
    }()
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    var presenter:TripDetialVCPresenter?
    init(presenter:TripDetialVCPresenter){
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        presenter.tripDetailedVC = self
        addFriendButtonDelegate = presenter
        addExpenseButtonDelegate = presenter
    }
    
    init(trip:TripDetails){
       // selectedTrip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureStackViewForAddButton()
        configureTripDetailTableView()
        
        navigationItem.largeTitleDisplayMode = .never
    }
    

    private func configureTripDetailTableView(){
        view.addSubview(tripDetailTableView)
        
        tripDetailTableView.delegate = presenter
        tripDetailTableView.dataSource = presenter
        
        tripDetailTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tripDetailTableView.topAnchor.constraint(equalTo: stackViewForAddButton.bottomAnchor, constant: 0),
            tripDetailTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tripDetailTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tripDetailTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            
        ])
        
        tripDetailTableView.register(AboutTableViewCell.self, forCellReuseIdentifier: AboutTableViewCell.identifier)
        tripDetailTableView.register(ExpenseListCell.self, forCellReuseIdentifier: ExpenseListCell.identifier)
        tripDetailTableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderView.identifier)
    }
    
    func configureStackViewForAddButton(){
        view.addSubview(stackViewForAddButton)
        stackViewForAddButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackViewForAddButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            stackViewForAddButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            stackViewForAddButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            stackViewForAddButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        stackViewForAddButton.addArrangedSubview(addFriendButton)
        stackViewForAddButton.addArrangedSubview(addExpenseButton)
    }
}



