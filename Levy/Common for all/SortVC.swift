//
//  SortVieController.swift
//  Levy
//
//  Created by Praveenraj T on 09/04/22.
//

import UIKit

protocol SortTripListDelegate:AnyObject{
    func updateSortKey(key:String)
}
protocol UpdateViewTransparencyDelegate:AnyObject{
    func updateAlpha()
}

class SortViewController: UIViewController {
    static let dateAse = "Date_ASC"
    static let dateDesc = "Date_DESC"
    static let nameAse = "Name_ASC"
    static let nameDesc = "Name_DESC"
    static let amountAsc = "Amount_ASC"
    static let amountDesc = "Amount_DESC"
    
    static let Ascending = "ASC"
    static let Descending = "DESC"
    
    static let dateRow = "Date"
    static let nameRow = "Name"
    static let amountRow = "Amount"
    static let keySplitter :Character = "_"

    weak var sortTripListDelegate:SortTripListDelegate?
    weak var updateViewTransparencyDelegate:UpdateViewTransparencyDelegate?
    
    var sortOptions = [SortViewController.dateRow,SortViewController.nameRow,SortViewController.amountRow]
    var updatePreselectedSortTypeDelegate:UpdatePreselectedSortTypeDelegate?
    
    var selectedOrder = SortViewController.Ascending
    
    var selectedSortBy = SortViewController.nameRow
    
    lazy var sortTypeSegmentButton:UISegmentedControl = {
        let items = ["Ascending","Descending"]
        let button = UISegmentedControl(items: items)
        button.addTarget(presenter , action: #selector(presenter?.segmentButtonDidTapped(_ :)), for: .valueChanged)
        return button
        
    }()
    
    let customCheck:UIImageView = {
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 30, height: 30)
        let image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(myThemeColor!)
        imageView.contentMode = .scaleToFill
        imageView.image = image
        return imageView
    }()
    
    let tableView = UITableView()
    
    var preSelectedOrder = String()
    
    lazy var doneBarButton:UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: presenter, action: #selector(presenter?.doneButtonDidTapped))
        button.isEnabled = false
        return button
    }()
    
    
    
    init(selectedKey:String){
        super.init(nibName: nil, bundle: nil)
        preSelectedOrder = selectedKey
        (selectedSortBy,selectedOrder) = SortVCPresenter.splitSortKey(sortKey: preSelectedOrder)
    }
    var presenter:SortVCPresenter?
    init(presenter:SortVCPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.presenter?.sortVC = self
        updatePreselectedSortTypeDelegate = self.presenter
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tertiarySystemBackground
        
        configureSegmentControl()
        configureTableView()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: presenter, action: #selector(presenter?.willCloseSortViewcontroller))
        navigationItem.rightBarButtonItem = doneBarButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter?.willCloseSortViewcontroller()
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            updatePreselectedSortTypeDelegate?.selectCurrentSortType()
    }
    
    func configureSegmentControl(){
        view.addSubview(sortTypeSegmentButton)
        sortTypeSegmentButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sortTypeSegmentButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 5),
            sortTypeSegmentButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            sortTypeSegmentButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }
    
    func configureTableView(){
        view.addSubview(tableView)
        tableView.allowsMultipleSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: sortTypeSegmentButton.bottomAnchor,constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
        tableView.dataSource = presenter
        tableView.delegate = presenter
        tableView.register(DefaultCell.self, forCellReuseIdentifier: DefaultCell.identifier)
    }

}

