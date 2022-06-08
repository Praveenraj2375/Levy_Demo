//
//  ShowFriendsListInTrip_ViewController.swift
//  Levy
//
//  Created by Praveenraj T on 14/03/22.
//

import UIKit


class ShowFriendsListInTripViewController: UIViewController{
    
    struct DataForTable{
        var id:String
        var name:String
        var phone: String
    }
    
    let tripDelegate :TripDetailDBDelegate = UseCase()
    let groupDetailDBDelegate:GroupDetailDBDelegate = UseCase()
    var friendsListUpdationDelegate:FriendsListUpdationDelegate?
    let tableView = UITableView()
    
    var tripID = Int()
    var groupID = Int()
    lazy var friendsInTrip = [FriendsInTrip]()
    var dataForTableView = [DataForTable]()
    var friendsInGroup = [FriendsInGroup]()
    
    
    init(selectedTripID:Int){
        super.init(nibName: nil, bundle: nil)
        friendsInTrip = tripDelegate.getEntireFrindsInTripFromDB(for: selectedTripID)
        tripID = selectedTripID
        title = "Friends In Trip"
    }
    
    init(selectedGroupID:Int){
        super.init(nibName: nil, bundle: nil)
        friendsInGroup = groupDetailDBDelegate.getFriendsInGroup(for: selectedGroupID)
        groupID = selectedGroupID
        title = "Friends in Group"
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        
        configureTableView()
        generateDataForTableView()
        
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func generateDataForTableView(){
        if friendsInTrip.count > 0{
            for friend in friendsInTrip{
                dataForTableView.append(DataForTable(id:friend.friendID,name: friend.friendName, phone: friend.friendPhoneNumber))
            }
        }
        else{
            for friend in friendsInGroup{
                dataForTableView.append(DataForTable(id:friend.friendID,name: friend.friendName, phone: friend.friendPhoneNumber))
            }
        }
    }
    
    func configureTableView(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.register(FriendsListTableViewCell.self, forCellReuseIdentifier: FriendsListTableViewCell.identifier)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let checkDueDelegate : FriendsDuesDelegate = UseCase()
        var isHaveDues = false
        if friendsInGroup.isEmpty{
            isHaveDues = checkDueDelegate.isFriendHaveDues(for: dataForTableView[indexPath.row].id, in: tripID,groupID: 0)
        }else{
            isHaveDues = checkDueDelegate.isFriendHaveDues(for: dataForTableView[indexPath.row].id, in:0,groupID: groupID)
        }
           
        var alert = UIAlertController(title: "⚠ Warning", message: "Are you sure want to remove the friend from trip permanently ?", preferredStyle: .actionSheet)
        if groupID != 0 {
            alert = UIAlertController(title: "⚠ Warning", message: "Are you sure want to remove the friend from group permanently ?", preferredStyle: .actionSheet)
        }
                
        let deleteAction = UIAlertAction(title: "Delete", style:.destructive , handler: { [self]_ in
            
            if self.friendsInGroup.isEmpty{
                let delegate :DeleteFriendFromTripDelegate  = UseCase()
                delegate.deleteFriendFromTrip(friendID: self.dataForTableView[indexPath.row].id, from: self.tripID)
            }else{
                let delgate : DeleteFriendsFromGroupDelegate = UseCase()
                delgate.deleteFriendFromGroup(friendID: self.dataForTableView[indexPath.row].id, from: self.groupID)
            }
            NotificationCenter.default.post(name: .friendDidRemoved, object: nil,userInfo: [UserInfoKeys.friendID:dataForTableView[indexPath.row].id])
            
            self.friendsInTrip.removeAll(where: {$0.friendID == self.dataForTableView[indexPath.row].id})
            self.friendsInGroup.removeAll(where: {$0.friendID == self.dataForTableView[indexPath.row].id})
            self.dataForTableView.remove(at: indexPath.row)
            isNewFriendAddedOrRemoved = true
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.friendsListUpdationDelegate?.updateFriendsList()
           
            
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
                throwWarningToUser(viewController: self, title: "\(self.dataForTableView[indexPath.row].name) have uncleared dues", errorMessage: "Please clear all dues before deleting friend detail.")
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

extension ShowFriendsListInTripViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if friendsInTrip.count > 0{
            return friendsInTrip.count
        }else{
            return friendsInGroup.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendsListTableViewCell.identifier) as? FriendsListTableViewCell
        guard let cell = cell else{
            print("error-unwrappingcell - showfriends")
            return UITableViewCell()
        }
        cell.setFriendNameLabel(with: dataForTableView[indexPath.row].name)
        cell.setPhoneNumberLabel(with: dataForTableView[indexPath.row].phone)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let phoneNo = "tel://\(dataForTableView[indexPath.row].phone)".replacingOccurrences(of: " ", with: "")
        
        guard let url = URL(string: phoneNo) else {
            print("url error")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url,options: [:])
        }
        else{
            print("call error")
        }
    }
    
}
