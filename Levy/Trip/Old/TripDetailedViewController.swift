//
//  TripDetailedViewController.swift
//  Levy
//
//  Created by Praveenraj T on 11/03/22.
//

import UIKit
import Contacts
import ContactsUI



//protocol TripDetailVCRefresherDelegate:AnyObject{
//    func refreshData()
//}
//
//protocol FriendsListUpdationDelegate:AnyObject{
//    func updateFriendsList()
//}

class TripDetailedViewControllerOld: UIViewController,UpdateFriendsDelegate {
    
    var tripDetailDBDelegate : TripDetailDBDelegate = UseCase()
    let expenseListDelegate : ExpenseTableDelegate = UseCase()
    let selectedTripDelegate : SelectedTripDelegate = UseCase()
    let groupNameFromDBDelegate:GroupNameFromDBDelegate = UseCase()
    let deleteExpenseDelegate:DeleteExpenseDelegate = UseCase()
    
    weak var tripListVCRefresherDelegate   : TripListVCRefresherDelegate?
    weak var groupDetailVCRefersherDelegate: GroupDetailVCRefersherDelegate?
    
    var friendsInTrip = Array<FriendsInTrip>()
    var selectedTrip:TripDetails = TripDetails(tripID: 0, tripName: "", startDate: "")
    weak var tripList :TripListViewController?
    
    var selectedIndexPath = IndexPath()
    
    var expenseListFromDB = [Expense]()
    
    lazy var pre1 = NSPredicate(format: "phoneNumbers.@count>0  ")
    lazy var arrayOfIdentifier = friendsInTrip.map({$0.friendID})
    lazy var pre2 = NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "identifier IN %@",argumentArray: [arrayOfIdentifier]))
    lazy var predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pre1,pre2])
    
    lazy var tripDetailTableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .secondarySystemBackground
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        return tableView
    }()
    
    private lazy var aboutTripData: [[String]] = [
        [ "Started On","Friends","My Share","Group"],
        [
            selectedTrip.startDate.replacingOccurrences(of: "\n",with: ","),
            selectedTrip.friendsCount.description,
            "",
            groupNameFromDBDelegate.getGroupName(for: selectedTrip.groupID) ?? "-"
        ]
    ]
    
    lazy var stackViewForAddButton:UIStackView = {
        let stackview = UIStackView()
        stackview.distribution = .fillEqually
        stackview.axis = .horizontal
        stackview.alignment = .center
        stackview.spacing = 50
        
        return stackview
    }()
    
    let buttonContainerView:UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemFill
        return view
    }()
    
    lazy var addFriendButton:UIButton = {
        let button = UIButton(type: .contactAdd)
        button.setTitle("Add Friends", for: .normal)
        
        button.setImage(UIImage(systemName: "person.crop.circle.badge.plus"), for: .normal)
        button.addTarget(self, action: #selector(addFriendButtonDidTapped), for: .touchUpInside)
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
            button.setImage(UIImage(named: "expense"), for: .normal)
        }
        
        if #available(iOS 15.0, *){
            var config = UIButton.Configuration.plain()
            config.imagePadding = 5
            button.configuration = config
            
        }else{
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        }
        
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(addExpenseButtonDidTapped), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        return button
    }()
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    init(trip:TripDetails){
        selectedTrip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        bringDataForUI()
        configureStackViewForAddButton()
        configureTripDetailTableView()
        
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tripListVCRefresherDelegate?.refreshData()
        groupDetailVCRefersherDelegate?.refreshGroupDetailVC()
        
    }
    
    override func bringDataForUI() {
        guard let selectedTripUpdateFromDB = selectedTripDelegate.getTripDetailFor(tripID: selectedTrip.tripID) else{
            print("***Error while unwrapping selectedTripUpdateFromDB ")
            return
        }
        selectedTrip = selectedTripUpdateFromDB
        friendsInTrip = []
        friendsInTrip.append(contentsOf:  tripDetailDBDelegate.getEntireFrindsInTripFromDB(for: selectedTrip.tripID))
        
        guard let expenseList = expenseListDelegate.getEntireExpenseListFromDB(for: selectedTrip.tripID) else{
            print("***Error: while getting ExpenseList From DB")
            return
        }
        
        expenseListFromDB = expenseList
        setAboutTripDetails(for: selectedTrip)
        tripDetailTableView.reloadData()
    }
    
    func setAboutTripDetails(for selectedTrip:TripDetails){
        aboutTripData[1][2] = currencyFormatter().string(from:  selectedTrip.myShare.magnitude as NSNumber) ?? " "
        if selectedTrip.myShare >= 0{
            aboutTripData[0][2] = "You're Owing"
            
        }else{
            aboutTripData[0][2] = "You Owe"
        }
        aboutTripData[0][3] = "Group"
        
        if selectedTrip.groupID != 0{
            if let groupName = groupNameFromDBDelegate.getGroupName(for: selectedTrip.groupID){
                aboutTripData[1][3] = groupName
            }
            
        }else{
            aboutTripData[1][3] = "-"
        }
    }
    
    
    private func configureTripDetailTableView(){
        view.addSubview(tripDetailTableView)
        
        tripDetailTableView.delegate = self
        tripDetailTableView.dataSource = self
        
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
    
    func updateFriends(friends: [ContactDetail]) {
        for friend in friends {
            addNewFriend(didSelect: friend)
        }
        tripDetailTableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
    }
    
}

//confirming to tableView delegate and datasource
extension TripDetailedViewControllerOld:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier) as? HeaderView
        guard let header = header else{
            return UITableViewHeaderFooterView()
        }
        var headerTitle = String()
        switch section{
        case 0: headerTitle =  "About Trip"
        case 1: headerTitle =  "Expenses"
        default: headerTitle =  " "
        }
        
        header.titleLabel.text = headerTitle
        
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            guard let rowCount = aboutTripData.first?.count else{
                print("*** error")
                return 0
            }
            return rowCount
        }
        else{
            return expenseListFromDB.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 40
        }
        else{return UITableView.automaticDimension}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: AboutTableViewCell.identifier) as? AboutTableViewCell
            guard let cell = cell else{
                print("*** errror-unwraping cell")
                return UITableViewCell()
            }
            cell.setDetailNameLabel(with: aboutTripData[0][indexPath.row])
            cell.setDetailValueLabel(with: aboutTripData[1][indexPath.row])
            
            if indexPath.row == 1{
                if selectedTrip.friendsCount > 0{
                    cell.accessoryType = .disclosureIndicator
                    
                    cell.isUserInteractionEnabled = true
                    
                }else{
                    cell.accessoryType = .none
                    cell.isUserInteractionEnabled = false
                    cell.setDetailValueLabel(with: "-")
                }
            }
            else{
                cell.isUserInteractionEnabled = false
                cell.accessoryType = .none
            }
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseListCell.identifier) as? ExpenseListCell
            
            guard let cell = cell else{
                print("cell creation error - tripdetailed vc")
                return UITableViewCell()
            }
            
            if !expenseListFromDB.isEmpty{
                cell.setDateViewLabel(with: expenseListFromDB[indexPath.row].expenseDate)
                cell.setExpenseNameLabel(with: expenseListFromDB[indexPath.row].expenseName)
                cell.setPaidByLabel(with:  expenseListFromDB[indexPath.row].paidByFriendName)
                cell.setMyShareLabel(with: expenseListFromDB[indexPath.row].myTotalShare)
                cell.setTotalAmountLabel(with: expenseListFromDB[indexPath.row].totalAmount)

            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 0{
            let showFriendsVC = ShowFriendsListInTripViewController(selectedTripID: selectedTrip.tripID)
            showFriendsVC.friendsListUpdationDelegate = self
            navigationController?.pushViewController(showFriendsVC, animated: true)
        }
        else{
            let expenseDetail = ExpenseDetailedViewController(expense: expenseListFromDB[indexPath.row])
            expenseDetail.title = expenseListFromDB[indexPath.row].expenseName
            expenseDetail.expenseUpdationDelegate = self
            navigationController?.pushViewController(expenseDetail, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0{
            return nil
        }
        var isHaveDues = false

        if expenseListFromDB[indexPath.row].myTotalShare != 0 {
            isHaveDues = true
        }
        
        
        let alert = UIAlertController(title: "⚠ Warning", message: "Are you sure want to remove the expense detail permanently ?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style:.destructive , handler: {_ in
            
            self.deleteExpenseDelegate.deleteExpense(for: self.expenseListFromDB[indexPath.row].expenseID)
            self.expenseListFromDB.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        })
        let keepAction = UIAlertAction(title: "Keep", style: .cancel, handler:nil)
        
        alert.addAction(deleteAction)
        alert.addAction(keepAction)
        alert.preferredAction = keepAction
        alert.popoverPresentationController?.sourceView = self.view
        if let cell = tableView.cellForRow(at: indexPath) as? TripListCell{
            alert.popoverPresentationController?.sourceView = cell
        }else{
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
        alert.popoverPresentationController?.permittedArrowDirections = .any
        
        let action = UIContextualAction(style: .destructive, title: "Delete") {_,_,completion in
            if isHaveDues{
            throwWarningToUser(viewController: self, title: "Expense have uncleared dues", errorMessage: "Please clear all dues before deleting an expense.")
                completion(true)
                return
            }
            
            self.present(alert, animated: true, completion: nil)
            completion(true)
        }
        let swipe =  UISwipeActionsConfiguration(actions: [action])
        return swipe
    }
    
}

//addExpense and addFriend button action implemented
extension TripDetailedViewControllerOld:CNContactPickerDelegate{
    
    func addNewFriend(didSelect contact: ContactDetail) {
        let newFriend = FriendWiseExpense(
            friendID: contact.identifier,
            name: contact.name,
            phoneNumber:contact.telephone,
            totalReturn: 0)
        
        guard let _ = tripDetailDBDelegate.inserIntoFriendWiseExpense(friend: newFriend)
        else{
            print("*** Error-insertion DB - TripDetailedViewController")
            return
        }
        
        let newFriendInTrip = FriendsInTrip(tripID: selectedTrip.tripID, friendID: contact.identifier, friendName: contact.name,friendPhoneNumber: contact.telephone)
        
        if tripDetailDBDelegate.insertIntoFriendsInTrip(value: newFriendInTrip){
            friendsInTrip.append(newFriendInTrip)
//            tripList?.tripDetailListData[selectedIndexPath.row].friendsCount += 1
            tripList?.tableView.reloadRows(at: [selectedIndexPath], with: .automatic)

            selectedTrip.friendsCount += 1
            aboutTripData[1][1] = selectedTrip.friendsCount.description

            tripDetailTableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
            arrayOfIdentifier.append(contact.identifier)
        }
        else{
            print("*** Error-TripDetailViewController")
        }
        bringDataForUI()
    }
    
    @objc func addFriendButtonDidTapped(){

        let contactPicker = customContactPicker()
        contactPicker.updateFriendsDelegate = self
        contactPicker.title = "Add Friends To Trip"
        contactPicker.preSelectedArrayOfIdentifier = friendsInTrip.map({$0.friendID})
        present(UINavigationController(rootViewController: contactPicker),animated: true)
    }
    
    
    @objc func addExpenseButtonDidTapped(){
        let newvc = InsertExpenseViewController(selectedTrip: selectedTrip.tripID)
        newvc.insertExpenseDelegate = self
        newvc.tripDetailVCRefresherDelegate = self
        
        if friendsInTrip.count == 0{
            newvc.paidByButton.isEnabled = false
            newvc.shareWithFriendsButton.isEnabled = false
            newvc.paidByButton.isHidden = true
            newvc.shareWithFriendsButton.isHidden = true
        }
        
        let nvc = UINavigationController(rootViewController: newvc)
        nvc.presentationController?.delegate = newvc
        present(nvc, animated: true)
    }
    
}

extension TripDetailedViewControllerOld:NewExpenseDetailDelegate{
    
    func insertIntoExpenseListTableView() {
       bringDataForUI()
    }
}

extension TripDetailedViewControllerOld:ExpenseUpdationDelegate{
    func updateExpenseDetail(expense: Expense,amount:Double) {
        guard let index = expenseListFromDB.firstIndex(where: {$0.expenseID == expense.expenseID}) else{
            return
        }
        expenseListFromDB[index].myTotalShare -= amount
        tripDetailTableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
//        tripList?.tripDetailListData[selectedIndexPath.row].myShare -= amount
        tripList?.tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        
        selectedTrip.myShare -= amount
        aboutTripData[1][2] = currencyFormatter().string(from: selectedTrip.myShare as NSNumber) ?? " "
        tripDetailTableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
    }
}

extension TripDetailedViewControllerOld:TripDetailVCRefresherDelegate,FriendsListUpdationDelegate{
    func refreshData() {
        self.bringDataForUI()
    }
    @objc func updateFriendsList() {
        guard let selectedTripUpdateFromDB = selectedTripDelegate.getTripDetailFor(tripID: selectedTrip.tripID) else{
            print("***Error while unwrapping selectedTripUpdateFromDB ")
            return
        }
        selectedTrip = selectedTripUpdateFromDB
        aboutTripData[1][1] = selectedTrip.friendsCount.description
        DispatchQueue.main.async {
            self.tripDetailTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        }
    }
}
