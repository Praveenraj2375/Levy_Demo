//
//  TripDetailVCPresenter.swift
//  Levy
//
//  Created by Praveenraj T on 31/05/22.
//

import Foundation
import UIKit

@objc protocol AddFriendButtonDelegate{
     func addFriendButtonDidTapped()
}

@objc protocol AddExpenseButtonDelegate{
    func addExpenseButtonDidTapped()
}

class TripDetialVCPresenter:NSObject{
    weak var tripDetailedVC:TripDetailedViewController?
    
    let tripDetailDBDelegate : TripDetailDBDelegate = UseCase()
    let expenseListDelegate : ExpenseTableDelegate = UseCase()
    let selectedTripDelegate : SelectedTripDelegate = UseCase()
    let groupNameFromDBDelegate:GroupNameFromDBDelegate = UseCase()
    let deleteExpenseDelegate:DeleteExpenseDelegate = UseCase()
    

    
    let startDateKey = "Started On"
    let friendsKey = "Friends"
    let owedBalanceKey = "You owed"
    let owingBalanceKey = "You're owing"
    let groupKey = "Group"
    lazy var aboutTripKeys = [startDateKey,groupKey,friendsKey,owedBalanceKey]
    lazy var aboutTrip:[String:String] = [
        startDateKey:selectedTrip.startDate.replacingOccurrences(of: "\n", with: ","),
        friendsKey:selectedTrip.friendsCount.description,
//        groupKey:groupNameFromDBDelegate.getGroupName(for: selectedTrip.groupID) ?? "-"
    
    ]
    
    var selectedIndexPath = IndexPath()
    var selectedTrip:TripDetails
    var expenseListFromDB = [Expense]()
    lazy var friendsInTrip : Array<FriendsInTrip> = tripDetailDBDelegate.getEntireFrindsInTripFromDB(for: selectedTrip.tripID)
    

    lazy var pre1 = NSPredicate(format: "phoneNumbers.@count>0  ")
    lazy var arrayOfIdentifier = friendsInTrip.map({$0.friendID})
    lazy var pre2 = NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "identifier IN %@",argumentArray: [arrayOfIdentifier]))
    lazy var predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pre1,pre2])
    
    init(trip:TripDetails){
        selectedTrip = trip
        if let expenseListFromDB = expenseListDelegate.getEntireExpenseListFromDB(for: trip.tripID){
            self.expenseListFromDB.append(contentsOf: expenseListFromDB)
        }
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(newFreindsDidAdded(_ :)), name: .newFriendDidAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(friendDidRemoved(_ :)), name: .friendDidRemoved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newExpenseDidAdded(_:)), name: .newExpenseDidAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tripDidDeleted(_:)), name: .tripDidDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(expenseDidDeleted(_:)), name: .expenseDidDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(expenseDidSettled(_:)), name: .expenseDidSettled, object: nil)
        
        let _ = willUpdateTotalReturnData(with: selectedTrip.myShare)
        
        
    }
    
    @objc func expenseDidSettled(_ notification:Notification){
        //1.get expID && settled amount
        //2.update exp detail
        //3.update total return
        //4.update trip detail
        guard let expID = notification.userInfo?[UserInfoKeys.expenseID] as? Int else{return}
        guard let settledAmount = notification.userInfo?[UserInfoKeys.settledAmount] as? Double else{return}
        updateSettledExpense(for: expID, settledAmount: settledAmount)
        selectedTrip.myShare -= settledAmount
        updateTotalReturn()
        willUpdateTripListData()
    }
    
    func updateSettledExpense(for expenseID:Int,settledAmount :Double){
        guard let expenseIndex = expenseListFromDB.firstIndex(where: {$0.expenseID == expenseID}) else {return}
        expenseListFromDB[expenseIndex].myTotalShare -= settledAmount
        DispatchQueue.main.async {
            self.tripDetailedVC?.tripDetailTableView.reloadRows(at: [IndexPath(row: expenseIndex, section: 1)], with: .automatic)
        }
    }
    
    @objc func expenseDidDeleted(_ notification:Notification){
        guard let expId = notification.userInfo?[UserInfoKeys.expenseID] as? Int else{
            return
        }
        guard let indexPath = notification.userInfo?[UserInfoKeys.indexPath] as? IndexPath else{
            return
        }
        willDeleteExpense(with: expId, at: indexPath)
    }
    
    @objc func tripDidDeleted(_ notification:Notification){
        guard let tripID = notification.userInfo?[UserInfoKeys.tripID] as? Int else{
            return
        }
        if tripID == selectedTrip.tripID{
            guard let tripDetailedVC = tripDetailedVC else{return}
            let alert = UIAlertController(title: "This Trip has been deleted", message: "The selected trip is deleted for server.Will close this detail view.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
                tripDetailedVC.navigationController?.popToRootViewController(animated: true)
            })
            alert.addAction(okAction)
            tripDetailedVC.present(alert, animated: true)
        }
    }
    
    @objc func friendDidRemoved(_ notification:Notification){
        //1.get removed friend id from user info
        //2.update friends count source
        //3. update ui
        //4. update triplistvc data
        guard let friendID = notification.userInfo?[UserInfoKeys.friendID] as? String else{
            return
        }
        friendsInTrip.removeAll(where: {$0.friendID == friendID})
        arrayOfIdentifier.removeAll(where: {$0 == friendID})
        selectedTrip.friendsCount -= 1
        aboutTrip[friendsKey] = selectedTrip.friendsCount.description
        willUpdateFriendsCountUI()
        
        willUpdateTripListData()
    }

    @objc func newExpenseDidAdded(_ notification:Notification){
        //1.get newly inserted expense from user info
        //2.update source
        //3.update ui
        //4.post notification for triplist update

        guard let expense = notification.userInfo?[UserInfoKeys.newExpense] as? Expense else{
            return
        }
        expenseListFromDB.insert(expense, at: 0)
        updateTripExpenseDetail(with: expense)
        DispatchQueue.main.async {
            self.tripDetailedVC?.tripDetailTableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            self.updateTotalReturn()
            self.tripDetailedVC?.tripDetailTableView.layoutIfNeeded()
        }
        willUpdateTripListData()
    }
    
    func updateTotalReturn(){
        let totalReturnIndexPath = willUpdateTotalReturnData(with: self.selectedTrip.myShare)
        self.tripDetailedVC?.tripDetailTableView.reloadRows(at: [totalReturnIndexPath] , with: .automatic)
    }
   
    func willUpdateTripListData(){
        NotificationCenter.default.post(name: .updateTripDetail, object: nil, userInfo: [UserInfoKeys.updateTrip:selectedTrip,UserInfoKeys.indexPath:selectedIndexPath])
    }
    
    func updateTripExpenseDetail(with expense:Expense){
        selectedTrip.totalExpense += expense.totalAmount
        selectedTrip.myShare += expense.myTotalShare
    }
    
    @objc func newFreindsDidAdded(_ notification:Notification){
        guard let friends = notification.userInfo?[UserInfoKeys.newFriend] as? [ContactDetail] else{
            return
        }
        for friend in friends {
            addNewFriend(from: friend)
        }
        willUpdateFriendsCountUI()
        willUpdateTripListData()
    }
    
    func willUpdateFriendsCountUI(){
        DispatchQueue.main.async {
            self.tripDetailedVC?.tripDetailTableView.reloadRows(at: [IndexPath(row: self.aboutTripKeys.firstIndex(of: self.friendsKey) ?? 2, section: 0)], with: .automatic)
            self.tripDetailedVC?.tripDetailTableView.layoutIfNeeded()
        }
    }
    
    func willUpdateTotalReturnData(with totalReturn:Double)->IndexPath{
        var row = Int(0)
        if totalReturn >= 0{
            removeOwingKey()
            insertOwedKey()
            aboutTrip[owedBalanceKey] = currencyFormatter().string(from:  totalReturn.magnitude as NSNumber) ?? " "
            if let first = aboutTripKeys.firstIndex(of: owedBalanceKey){
                row = first
            }
            
        }else{
            removeOwedKey()
            insertOwingKey()
            aboutTrip[owingBalanceKey] = currencyFormatter().string(from:  totalReturn.magnitude as NSNumber) ?? " "
            if let first = aboutTripKeys.firstIndex(of: owingBalanceKey){
                row = first
            }
        }
        return IndexPath(row: row, section: 0)

    }
    
    
    func removeOwingKey(){
        aboutTripKeys.removeAll(where: {$0 == owingBalanceKey})
        aboutTrip[owingBalanceKey] = nil
    }
    
    func insertOwedKey(){
        if !aboutTripKeys.contains(owedBalanceKey){
            aboutTripKeys.append(owedBalanceKey)
        }
    }
    
    func insertOwingKey(){
        if !aboutTripKeys.contains(owingBalanceKey){
            aboutTripKeys.append(owingBalanceKey)
        }
    }
    
    func removeOwedKey(){
        aboutTripKeys.removeAll(where: {$0 == owedBalanceKey})
        aboutTrip[owedBalanceKey] = nil
    }
}

extension TripDetialVCPresenter:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier) as? HeaderView else{
            return UITableViewHeaderFooterView()
        }
        let headerTitle = getSectionHeader(for: section)
        header.titleLabel.text = headerTitle
        return header
    }
    
    func getSectionHeader(for section:Int)->String{
        var headerTitle = String()
        switch section{
        case 0: headerTitle =  "About Trip"
        case 1: headerTitle =  "Expenses"
        default: headerTitle =  " "
        }
        return headerTitle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return aboutTripKeys.count
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
            let cell = getAboutTripCell(tableView, for: indexPath.row)
            return cell
        }
        else{
            let cell = getExpenseListCell(tableView, for: indexPath.row)
            return cell
        }
    }
    
    func getExpenseListCell(_ tableView:UITableView,for item:Int)->UITableViewCell{
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseListCell.identifier) as? ExpenseListCell
        else{
            print("cell creation error - tripdetailed vc")
            return UITableViewCell()
        }
        
        cell.setDateViewLabel(with: expenseListFromDB[item].expenseDate)
        cell.setExpenseNameLabel(with: expenseListFromDB[item].expenseName)
        cell.setPaidByLabel(with:  expenseListFromDB[item].paidByFriendName)
        cell.setMyShareLabel(with: expenseListFromDB[item].myTotalShare)
        cell.setTotalAmountLabel(with: expenseListFromDB[item].totalAmount)
        return cell
    }
    
    func getAboutTripCell(_ tableView:UITableView,for item:Int)->UITableViewCell{
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AboutTableViewCell.identifier) as? AboutTableViewCell else{
            print("*** errror-unwraping cell")
            return UITableViewCell()
        }
        let key = aboutTripKeys[item]
        cell.setDetailNameLabel(with: key)
        cell.setDetailValueLabel(with: aboutTrip[key] ?? "-")
        
        if key == friendsKey && selectedTrip.friendsCount > 0{
            cell.accessoryType = .disclosureIndicator
            cell.isUserInteractionEnabled = true
        }else{
            cell.isUserInteractionEnabled = false
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 0{
            let showFriendsVC = ShowFriendsListInTripViewController(selectedTripID: selectedTrip.tripID)
            //showFriendsVC.friendsListUpdationDelegate = self
            tripDetailedVC?.show(showFriendsVC, sender: nil)
        }
        else{
            let expenseDetail = ExpenseDetailedViewController(expense: expenseListFromDB[indexPath.row])
            expenseDetail.title = expenseListFromDB[indexPath.row].expenseName
            tripDetailedVC?.show(expenseDetail, sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0{
            return nil
        }
        
        let action = UIContextualAction(style: .destructive, title: "Delete") {_,_,completion in
            self.tableViewTailDidSwiped(at: indexPath)
            completion(true)
        }
        action.image = UIImage(systemName: "trash")
        let swipe =  UISwipeActionsConfiguration(actions: [action])
        return swipe
    }
    
    func willDeleteExpense(with expID:Int,at indexPath:IndexPath){
        deleteExpenseDelegate.deleteExpense(for:expID)
        if expenseListFromDB.contains(where: {$0.expenseID == expID}){
            expenseListFromDB.removeAll(where: {$0.expenseID == expID})
            tripDetailedVC?.tripDetailTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableViewTailDidSwiped(at indexPath:IndexPath){
        guard let tripDetailedVC = tripDetailedVC else{ return }
        if isExpenseHaveDues(at: indexPath){
            //throw warning
            throwWarningToUser(viewController: tripDetailedVC, title: "Expense have uncleared dues", errorMessage: "Please clear all dues before deleting an expense.")
        }else{
            //ask user to confirm deletion
            shouldDeleteExpenseDetail(onCompletion: {isDeletionConfirmed in
                if isDeletionConfirmed{
                    //delete expense
                    self.willDeleteExpense(with: self.expenseListFromDB[indexPath.row].expenseID, at: indexPath)
                    NotificationCenter.default.post(name: .expenseDidDeleted, object: nil,userInfo: [UserInfoKeys.expenseID:self.expenseListFromDB[indexPath.row].expenseID,UserInfoKeys.indexPath:indexPath ])
                }  //else skip deletion
                return
            })
        }
    }
    
    func shouldDeleteExpenseDetail(onCompletion:@escaping(Bool)->Void){
        let alert = UIAlertController(title: "⚠ Warning", message: "Are you sure want to remove the expense detail permanently ?", preferredStyle: .actionSheet)
        let keepAction = UIAlertAction(title: "Keep", style: .cancel, handler:{_ in
            onCompletion(false)
        })
        let deleteAction = UIAlertAction(title: "Delete", style:.destructive , handler: {_ in
            onCompletion(true)
        })
        alert.addAction(keepAction)
        alert.addAction(deleteAction)
        alert.popoverPresentationController?.sourceView = self.tripDetailedVC?.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        alert.preferredAction = keepAction
        alert.popoverPresentationController?.permittedArrowDirections = .any
        self.tripDetailedVC?.present(alert, animated: true, completion: nil)
    }
    
    func isExpenseHaveDues(at indexPath:IndexPath)->Bool{
        if expenseListFromDB[indexPath.row].myTotalShare != 0 {
            return true
        }else{
            return false
        }
    }
}


//addExpense and addFriend button action implemented
extension TripDetialVCPresenter:AddFriendButtonDelegate,AddExpenseButtonDelegate{
    
    func addNewFriend(from contact: ContactDetail) {
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
            selectedTrip.friendsCount += 1
            aboutTrip[friendsKey] = selectedTrip.friendsCount.description
            arrayOfIdentifier.append(contact.identifier)
        }
        else{
            print("*** Error-TripDetailViewController")
        }
    }
    
    @objc func addFriendButtonDidTapped(){
        let contactPicker = customContactPicker()
        contactPicker.title = "Add Friends To Trip"
        contactPicker.preSelectedArrayOfIdentifier = friendsInTrip.map({$0.friendID})
        tripDetailedVC?.present(UINavigationController(rootViewController: contactPicker),animated: true)
    }
    
    @objc func addExpenseButtonDidTapped(){
        let newvc = InsertExpenseViewController(selectedTrip: selectedTrip.tripID)
        if friendsInTrip.count == 0{
            newvc.paidByButton.isEnabled = false
            newvc.shareWithFriendsButton.isEnabled = false
            newvc.paidByButton.isHidden = true
            newvc.shareWithFriendsButton.isHidden = true
        }
        
        let nvc = UINavigationController(rootViewController: newvc)
        nvc.presentationController?.delegate = newvc
        tripDetailedVC?.present(nvc, animated: true)
    }
    
}
extension TripDetialVCPresenter:FriendsListUpdationDelegate{
    
    @objc func updateFriendsList() {
        guard let selectedTripUpdateFromDB = selectedTripDelegate.getTripDetailFor(tripID: selectedTrip.tripID) else{
            print("***Error while unwrapping selectedTripUpdateFromDB ")
            return
        }
        selectedTrip = selectedTripUpdateFromDB
        aboutTrip[friendsKey] = selectedTrip.friendsCount.description
        DispatchQueue.main.async {
            self.tripDetailedVC?.tripDetailTableView.reloadRows(at: [IndexPath(row: self.aboutTripKeys.firstIndex(of: self.friendsKey) ?? 0, section: 0)], with: .automatic)
        }
    }
}
