
import Foundation
import UIKit

class NewTripViewController:NewDetailInsertionVC{

    let memberCountLabelSuffix = " Friends Added"
    let tripDetailDBDelegate : TripDetailDBDelegate = UseCase()
    let groupDBDelegate : GroupDBDelegate = UseCase()
    let tripDetailDelgate:TripListDelegate = UseCase()
    
    weak var tripListVCRefresherDelegate:TripListVCRefresherDelegate?
    
    
    private lazy var pre1 = NSPredicate(format: "phoneNumbers.@count>0  ")
    private lazy var arrayOfIdentifier = [String]()
    private lazy var pre2 = NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "identifier IN %@",argumentArray: [arrayOfIdentifier]))
    private lazy var predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pre1,pre2])
    
    var selectedFriendsFromContact = [ContactDetail]()
    
    private let addFriendButtonImage = UIImage(systemName: "person.crop.circle.badge.plus")
    
    lazy var addFriendButton:UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = myThemeColor
        button.setTitle("Add Friends ", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.tintColor = .white
        button.setImage(UIImage(systemName: "person.crop.circle.badge.plus"), for: .normal)
        
        if #available(iOS 15.0, *){
            var config = UIButton.Configuration.borderless()
            config.imagePlacement = .trailing
            config.imagePadding = 10
            button.configuration = config
        }else{
            button.semanticContentAttribute = .forceRightToLeft
        }
        button.setContentHuggingPriority(UILayoutPriority(256), for: .vertical)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        return button
    }()
    
    lazy var friendsCountLabel:UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.setContentHuggingPriority(UILayoutPriority(255), for: .vertical)
        return label
    }()
    
    let selectedFriendsTableView:SelfSizingTableView = {
        let tableView = SelfSizingTableView()
        tableView.isScrollEnabled = false
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.systemTeal.cgColor
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabelBottom.isActive = false
        datePickerView.minimumDate = Calendar.current.date(from: minDateComponent)
        
        configureAddFriendButton()
        configureFriendsCountLabel()
        setMemberCountLabelText()
        configureSelectedFriendsTableView()
        
        isModalInPresentation = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tripListVCRefresherDelegate?.refreshData()
    }
    
    
    private func configureAddFriendButton(){
        containerView.addSubview(addFriendButton)
        addFriendButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addFriendButton.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            addFriendButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        addFriendButton.addTarget(self, action: #selector(addFriendButtonDidTapped), for: .touchUpInside)
    }
    
    private func configureFriendsCountLabel(){
        containerView.addSubview(friendsCountLabel)
        friendsCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            friendsCountLabel.centerXAnchor.constraint(equalTo: addFriendButton.centerXAnchor),
            friendsCountLabel.topAnchor.constraint(equalTo: addFriendButton.bottomAnchor,constant: 10),
            friendsCountLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -10),
            friendsCountLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setMemberCountLabelText(){
        var string = ""
        switch arrayOfIdentifier.count{
            case 0 : string = "No Friends Added"
            case 1 : string = "1 Friend Added"
            default : string = arrayOfIdentifier.count.description+memberCountLabelSuffix
        }
        friendsCountLabel.text = string
    }
    
    override func doneButtonDidTapped(){
        nameTextField.resignFirstResponder()
        guard let tripName = nameTextField.text else{
            print("trip name field text retrivel error @ NewDetailInsertionVC")
            return
        }
        
        guard let newTrip = tripDetailDelgate.insertNewTripIntoDB(tripName: tripName, date: selectedDateString, groupID: groupID ?? 0) else {
            print("*** Error: newtrip unwrap error - NewDetailInsertionVC")
            let actionSheet = UIAlertController(title: "Error", message: "Not able to insert new Value into DB", preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            actionSheet.popoverPresentationController?.sourceView = self.view
            let xOrigin = 0
            let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
            actionSheet.popoverPresentationController?.sourceRect = popoverRect
            actionSheet.popoverPresentationController?.permittedArrowDirections = .up
            
            present(actionSheet,animated: true)
            return
        }
        
        isNewTripAdded = true
        
        updateFriends(friends: selectedFriendsFromContact,tripID: newTrip.tripID)
        delegate?.insertIntoTableView()
        dateFormatter.dateFormat = "MMM\ndd\nyyyy"
        var updatedNewTrip = newTrip
        updatedNewTrip.startDate = dateFormatter.string(from: datePickerView.date)
        NotificationCenter.default.post(name: .newTripDidAdded, object: nil, userInfo: [UserInfoKeys.newTrip:updatedNewTrip])
        dismiss(animated: true, completion: nil)
    }
    
    override func cancelButtonDidTapped(){
        nameTextField.resignFirstResponder()
        if doneBarButton.isEnabled || !selectedFriendsFromContact.isEmpty {
            let alerSheet = UIAlertController(title: nil, message: "Are you sure you want to discard this new trip?", preferredStyle: .actionSheet)
            alerSheet.addAction(UIAlertAction(title: "Keep Editing", style: .cancel, handler: nil))
            alerSheet.addAction(UIAlertAction(title: "Discard Changes", style: .destructive, handler: {_ in
                self.dismiss(animated: true, completion: nil)
            }))
            alerSheet.popoverPresentationController?.sourceView = self.view
            let xOrigin = 0
            let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
            alerSheet.popoverPresentationController?.sourceRect = popoverRect
            alerSheet.popoverPresentationController?.permittedArrowDirections = .up
            present(alerSheet,animated: true)
        }
        else{
            dismiss(animated: true, completion: nil)
        }
    }
    

    func configureSelectedFriendsTableView(){
        containerView.addSubview(selectedFriendsTableView)
        selectedFriendsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        selectedFriendsTableView.topAnchor.constraint(equalTo: friendsCountLabel.bottomAnchor,constant: 10).isActive = true
        selectedFriendsTableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        selectedFriendsTableView.safeAreaLayoutGuide.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        selectedFriendsTableView.safeAreaLayoutGuide.widthAnchor.constraint(equalTo: containerView.widthAnchor,constant: -4).isActive = true
        
        selectedFriendsTableView.dataSource = self
        selectedFriendsTableView.delegate = self
        
        selectedFriendsTableView.register(SelectedFriendsListCell.self, forCellReuseIdentifier: SelectedFriendsListCell.identifier)
    }
}

extension NewTripViewController:UITableViewDataSource,UITableViewDelegate,RemoveFriendsFromSelectedFreindsDelegate{
    func removeFriend(at cell: UITableViewCell) {
        if let index = selectedFriendsTableView.indexPath(for: cell) {
            let deletedFriendID =  selectedFriendsFromContact[index.row].identifier
            selectedFriendsFromContact.removeAll(where: {$0.identifier == deletedFriendID})
            arrayOfIdentifier.removeAll(where: {$0 == deletedFriendID})
            selectedFriendsTableView.deleteRows(at: [index], with: .automatic)
            //selectedFriendsTableView.layoutIfNeeded()
            setMemberCountLabelText()
        }else{
            print("***Error cell not found")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selectedFriendsFromContact.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectedFriendsListCell.identifier) as? SelectedFriendsListCell
        guard let cell = cell else{
            print("*** Error: while unwrapping cell @ friendslistVCForSplit")
            return UITableViewCell()
        }
        cell.setNameLable(with: selectedFriendsFromContact[indexPath.row].name)
        cell.setPhoneNumberLabel(with: selectedFriendsFromContact[indexPath.row].telephone)
        cell.removeFriendsFromSelectedFreindsDelegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       
        let action = UIContextualAction(style: .destructive, title: "Delete") {_,_,completion in
            guard let cell = self.selectedFriendsTableView.cellForRow(at: indexPath) as? SelectedFriendsListCell else{
                return
            }
            cell.deleteButtonDidTapped()
            completion(true)
        }
        let swipe =  UISwipeActionsConfiguration(actions: [action])
        return swipe
    }
    
}

extension NewTripViewController{
    func updateFriends(friends: [ContactDetail],tripID:Int) {
        for friend in friends {
            addNewFriend(didSelect: friend,tripID: tripID)
        }
    }
    
    func addNewFriend(didSelect contact: ContactDetail,tripID:Int) {
        let newFriend = FriendWiseExpense(
            friendID: contact.identifier,
            name: contact.name,
            phoneNumber:contact.telephone,
            totalReturn: 0)
        
        guard let _ = tripDetailDBDelegate.inserIntoFriendWiseExpense(friend: newFriend) else{
            print("*** Error-insertion DB - TripDetailedViewController")
            return
        }
        
        let friendIntrip = FriendsInTrip(tripID: tripID, friendID: contact.identifier, friendName: contact.name,friendPhoneNumber: contact.telephone)
        let isInsertIntoDB = tripDetailDBDelegate.insertIntoFriendsInTrip(value: friendIntrip)
        
        if !isInsertIntoDB{
            throwWarningToUser(viewController: self, title: "Error", errorMessage: "Something went wrong.Try after sometime")
        }
    }
    
    @objc func addFriendButtonDidTapped(){
        let vc = customContactPicker()
        vc.updateFriendsDelegate = self
        vc.title = "Add Friends"
        vc.preSelectedArrayOfIdentifier = selectedFriendsFromContact.map({$0.identifier})
        present(UINavigationController(rootViewController: vc),animated: true)
    }
}


extension NewTripViewController:UpdateFriendsDelegate{
    func updateFriends(friends: [ContactDetail]) {
        for friend in friends{
            if let index = selectedFriendsFromContact.firstIndex(where: {$0.name > friend.name}) {
                insertNewFriend(at: index, friend: friend)
            }else{
                insertNewFriend(at: selectedFriendsFromContact.count, friend: friend)
            }
        }
        arrayOfIdentifier = selectedFriendsFromContact.map({$0.identifier})
        setMemberCountLabelText()
    }
    
    func insertNewFriend(at index:Int,friend:ContactDetail){
        selectedFriendsFromContact.insert(friend, at: index)
        selectedFriendsTableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        selectedFriendsTableView.layoutIfNeeded()
    }
}

extension NewTripViewController{
    override func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        cancelButtonDidTapped()
    }
}
