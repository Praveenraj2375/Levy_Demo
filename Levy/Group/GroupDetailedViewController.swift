//
//  GroupDetailedViewController.swift
//  Levy
//
//  Created by Praveenraj T on 30/03/22.
//

import UIKit
import Contacts
import ContactsUI

protocol TripListVCRefresherDelegate:AnyObject{
    func refreshData()
}

protocol GroupListVCRefersherDelegate:AnyObject{
    func refresh()
}

protocol GroupDetailVCRefersherDelegate:AnyObject{
    func refreshGroupDetailVC()
}

class GroupDetailedViewController: TripDetailedViewController {
    
    static let tripListCellIdentifier = "tripListCell"
    static let friendsListCellIdentifier = "friendsListCell"
    static let detailedCellIdentifier = "detailedCell"
    
    let groupDetailDBDelegate:GroupDetailDBDelegate = UseCase()
    let groupDBDelegate:GroupDBDelegate = UseCase()
    let selectedGroupDelegate:SelectedGroupDelegate = UseCase()
    let tripDeletionDelegate : DeleteTripDelegate = UseCase()
    weak var groupListVCRefersherDelegate:GroupListVCRefersherDelegate?
    
    var tripListData = [TripDetails]()
    var friendsInGroupFromDB = [FriendsInGroup]()
    var selectedGroup  : GroupDetails?
    lazy var aboutGroup = [NSMutableAttributedString]()
    
    var tableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none

        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = selectedGroup?.groupName
        tripDetailTableView.removeFromSuperview()
        
        addExpenseButton.setTitle("Add Trip", for: .normal)
        configureTableview()
        bringDataForUI()
        
//        addExpenseButton.removeTarget(self, action: #selector(addExpenseButtonDidTapped), for: .touchUpInside)
        addExpenseButton.addTarget(self, action: #selector(addTripButtonDidTapped), for: .touchUpInside)
//        addFriendButton.removeTarget(self, action: #selector(super.addFriendButtonDidTapped), for: .touchUpInside)
        addFriendButton.addTarget(self, action: #selector(addFriendButtonDidTapped), for: .touchUpInside)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        groupListVCRefersherDelegate?.refresh()
    }
    
    override func bringDataForUI() {
        selectedGroup = selectedGroupDelegate.getGroupDetail(for: selectedGroup?.groupID ?? 0)
        
        guard let selectedGroup = selectedGroup else {
            print("***Error while unwrapping selected Group")
            return
        }
        
        tripListData = groupDetailDBDelegate.getTripDetailForGroup(groupID: selectedGroup.groupID)
       
        
        friendsInGroupFromDB = groupDetailDBDelegate.getFriendsInGroup(for: selectedGroup.groupID)
        //arrayOfIdentifier = friendsInGroupFromDB.map({$0.friendID})
        
        updateAboutGroupDetails()
        tableView.reloadData()
    }
    
    func updateAboutGroupDetails(){
        aboutGroup = []
        
        guard let selectedGroup = selectedGroupDelegate.getGroupDetail(for: selectedGroup?.groupID ?? 0) else {
            print("***Error while unwrapping selected Group")
            return
        }
        self.selectedGroup?.friendsCountInGroup = selectedGroup.friendsCountInGroup
        self.selectedGroup?.amount = selectedGroup.amount
       
        aboutGroup.append(NSMutableAttributedString(string: selectedGroup.groupDescription))
        if selectedGroup.amount >= 0{
            aboutGroup.append(NSMutableAttributedString(string:"You're Owing "+(currencyFormatter().string(from: selectedGroup.amount as NSNumber) ?? "0"),attributes: [.foregroundColor : UIColor.systemGreen,.font:UIFont.boldSystemFont(ofSize: 20)]))
        }
        else{
            aboutGroup.append(NSMutableAttributedString(string:"You Owe "+(currencyFormatter().string(from: selectedGroup.amount.magnitude as NSNumber) ?? "0"),attributes: [.foregroundColor : UIColor.systemRed,.font:UIFont.boldSystemFont(ofSize: 20)]))
        }
        
        if selectedGroup.friendsCountInGroup == 1{
            aboutGroup.append(NSMutableAttributedString(string:"1 Friend"))
        }else if selectedGroup.friendsCountInGroup == 0 {
            aboutGroup.append(NSMutableAttributedString(string:"No Friend"))
        }else{
            aboutGroup.append(NSMutableAttributedString(string:selectedGroup.friendsCountInGroup.description+" Friends"))
        }
    }
    
    override init(){
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTableview(){
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: stackViewForAddButton.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        assginDelegateForTableView()
        guard let selectedGroup = selectedGroup else {
            return
        }
        
        self.selectedGroup?.groupID = selectedGroup.groupID
        
        tableView.register(TripListCell.self, forCellReuseIdentifier: TripListCell.identifier)
        tableView.register(DefaultCell.self, forCellReuseIdentifier: DefaultCell.identifier)
        tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderView.identifier)
    }
    
    func assginDelegateForTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc  func addTripButtonDidTapped(){
        let newTripVC = NewDetailInsertionVC(groupID: selectedGroup?.groupID ?? 0)
        
        newTripVC.presentingGroupVC = self
        let insertVC = UINavigationController(rootViewController: newTripVC)
        
        insertVC.view.backgroundColor = .systemBackground
        insertVC.presentationController?.delegate = newTripVC
        present(insertVC,animated: true)
        
    }
    
    @objc  func addFriendButtonDidTapped(){
        let contactPicker = customContactPicker()
        //contactPicker.updateFriendsDelegate = self
        contactPicker.title = "Add Friends To Group"
        //contactPicker.preSelectedArrayOfIdentifier = arrayOfIdentifier
        present(UINavigationController(rootViewController: contactPicker),animated: true)
    }
    
    func updateFriends(friends: [ContactDetail]) {
        for friend in friends {
            //arrayOfIdentifier.append(friend.identifier)
            insertFriendsIntoDB(contact: friend, groupID: selectedGroup?.groupID ?? 0)
        }
        friendsInGroupFromDB = groupDetailDBDelegate.getFriendsInGroup(for: selectedGroup?.groupID ?? 0)
        updateAboutGroupDetails()
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func insertFriendsIntoDB( contact: ContactDetail,groupID:Int) {
//        let newFriend = FriendWiseExpense(
//            friendID: contact.identifier,
//            name: contact.name,
//            phoneNumber:contact.telephone,
//            totalReturn: 0)
        
//        guard let _ = tripDetailDBDelegate.inserIntoFriendWiseExpense(friend: newFriend)
//        else{
//            print("*** Error-insertion DB - TripDetailedViewController")
//            return
//        }
        groupDBDelegate.insertIntoFriendsInGroup(friend: FriendsInGroup(groupID: groupID, friendID: contact.identifier))
    }
    
}


extension GroupDetailedViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0 : return aboutGroup.count
        case 1 : return tripListData.count
            
        default:
            return 5
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier) as? HeaderView
        guard let header = header else{
            return UITableViewHeaderFooterView()
        }
        var headerTitle = String()
        switch section{
        case 0: headerTitle =  "About Group"
        case 1: headerTitle =  "Trips"
        default: headerTitle =  " "
        }
        
        header.titleLabel.text = headerTitle
        return header
    }
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: DefaultCell.identifier) as? DefaultCell
            guard let cell = cell else {
                return UITableViewCell()
            }
            
            cell.titleLabel.attributedText = aboutGroup[indexPath.row]
            cell.titleLabel.textAlignment = .left
            
            if indexPath.row == 2{
                cell.selectionStyle = .default
                if selectedGroup?.friendsCountInGroup ?? 0 > 0{
                cell.accessoryType = .disclosureIndicator
                    cell.isUserInteractionEnabled = true

                }else{
                    cell.accessoryType = .none
                    cell.isUserInteractionEnabled = false
                }
            }else{
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = .none
                cell.accessoryType = .none
            }
            return cell
            
        }
        else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: TripListCell.identifier) as? TripListCell
            guard let cell = cell else{
                print("***Error While Unwrapping cell @ GroupDetailviewController")
                return UITableViewCell()
            }
            
            
            cell.setDateViewLable(with: tripListData[indexPath.row].startDate)
            cell.setTripNameLable(with: tripListData[indexPath.row].tripName)
            cell.setFriendsCountLabel(with: tripListData[indexPath.row].friendsCount)
            cell.setMyShareLabel(with: tripListData[indexPath.row].myShare)
            cell.setTotalAmountLabel(with: tripListData[indexPath.row].totalExpense)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0{
            if indexPath == IndexPath(row: 2, section: 0){
                let newVC = ShowFriendsListInTripViewController(selectedGroupID: selectedGroup?.groupID ?? 0)
               // newVC.friendsListUpdationDelegate = self
                navigationController?.pushViewController(newVC, animated: true)
            }
        }else{
            let newVC = TripDetailedViewController(trip: tripListData[indexPath.row])
            newVC.title = tripListData[indexPath.row].tripName
            
            newVC.groupDetailVCRefersherDelegate = self
//            newVC.selectedIndexPath = indexPath
            newVC.navigationController?.navigationBar.prefersLargeTitles = false
            navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0{
            return nil
        }
        var isHaveDues = false
        
        if tripListData[indexPath.row].myShare != 0{
            isHaveDues = true
        }
        
        let alert = UIAlertController(title: "⚠ Warning", message: "Are you sure want to remove trip detail permanently ?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style:.destructive , handler: {_ in
            self.tripDeletionDelegate.deleteTrip(for: self.tripListData[indexPath.row].tripID)
            self.tripListData.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        })
        let keepAction = UIAlertAction(title: "Keep", style: .cancel, handler:nil)
        
        alert.addAction(deleteAction)
        alert.addAction(keepAction)
        alert.preferredAction = keepAction
        if let cell = tableView.cellForRow(at: indexPath) as? TripListCell{
            alert.popoverPresentationController?.sourceView = cell
        }else{
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
        alert.popoverPresentationController?.permittedArrowDirections = .any
        
        let action = UIContextualAction(style: .destructive, title: "Delete") {_,_,completion in
            if isHaveDues{
            throwWarningToUser(viewController: self, title: "Trip have uncleared dues", errorMessage: "Please clear all dues before deleting trip detail.")
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



extension GroupDetailedViewController:GroupDetailVCRefersherDelegate{
    func refreshGroupDetailVC() {
        bringDataForUI()
    }
    
    func updateFriendsList() {
        updateAboutGroupDetails()
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
}
