//
//  SelectedFriendsListFromContact.swift
//  Levy
//
//  Created by Praveenraj T on 04/04/22.
//

import UIKit
import Contacts
import ContactsUI

struct FriendDetail{
    var id:String
    var name:String
    var phoneNumber:String
}

protocol ShowFriendsDelegate:AnyObject{
    func updateFriends(list:[ContactDetail])
}

class SelectedFriendsListFromContact :UIViewController{

   
    let myName = "Me "
    let myID = "0"
    
    var isMultiSelectionEnabled = false
    
    var totalRowSelected = [String]()
    
    weak var showFriendsDelegate:ShowFriendsDelegate?
    weak var NewDetailVC :NewTripViewController?
    
    var selectFriendsOld = [ContactDetail]()
    var selectedFriends = [ContactDetail]()
    
    lazy var doneBarButton:UIBarButtonItem = {
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonDidTapped))
       done.isEnabled  = false
       return done
   }()
    
    let tableView :UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .systemBackground
        return table
    }()
    
    lazy var addFriendButton:UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
       
        button.setTitle("Add Friends ", for: .normal)
        button.setImage(UIImage(systemName: "person.crop.circle.badge.plus"), for: .normal)
        
        if #available(iOS 15.0, *){
            var config = UIButton.Configuration.borderless()
            config.imagePlacement = .trailing
            config.imagePadding = 10
            button.configuration = config
        }else{
            button.semanticContentAttribute = .forceRightToLeft
        }

        return button
    }()
    
    init(){
        super.init(nibName: nil, bundle: nil)
        title = "Selected Friends"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidTapped))
        navigationController?.navigationBar.backgroundColor = .systemBackground
        
        self.isModalInPresentation = true
        configureTableView()
    }
    
    func configureTableView(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.register(SelectedFriendsListCell.self, forCellReuseIdentifier: "friends")
    }
    
    @objc func doneButtonDidTapped(){
        showFriendsDelegate?.updateFriends(list: selectedFriends)
        dismiss(animated: true)
    }
    
    @objc func cancelButtonDidTapped(){
        if doneBarButton.isEnabled{
            let actionSheet = UIAlertController(title: nil, message: "Do you want to save changes?", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "save changes", style: .cancel, handler: {_ in self.doneButtonDidTapped()}))
            actionSheet.addAction(UIAlertAction(title: "Discard Changes", style: .destructive, handler: {_ in
                self.dismiss(animated: true, completion: nil)
            }))
            actionSheet.popoverPresentationController?.sourceView = self.view
            let xOrigin = 0 
            let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
            actionSheet.popoverPresentationController?.sourceRect = popoverRect
            actionSheet.popoverPresentationController?.permittedArrowDirections = .up
            present(actionSheet,animated: true)
            
            
        }else{
            showFriendsDelegate?.updateFriends(list: selectFriendsOld)
            dismiss(animated: true)

        }
        
    }
    
    func configureAddContactButton(){
        tableView.addSubview(addFriendButton)
        addFriendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addFriendButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            addFriendButton.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            addFriendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        addFriendButton.addTarget(self, action: #selector(addFriendButtonDidTapped), for: .touchUpInside)
    }
    
    @objc func addFriendButtonDidTapped(){
        let vc = customContactPicker()
        vc.updateFriendsDelegate = self
        vc.title = "Select Friends"
        vc.preSelectedArrayOfIdentifier =  selectedFriends.map({$0.identifier})
        present(UINavigationController(rootViewController: vc),animated: true)
        
        tableView.reloadData()
    }

}

extension SelectedFriendsListFromContact:UpdateFriendsDelegate{
    func updateFriends(friends: [ContactDetail]) {
        totalRowSelected.append(contentsOf: friends.map({$0.identifier}))
        selectedFriends.append(contentsOf: friends)
        selectedFriends.sort(by: {$0.name < $1.name})
        doneBarButton.isEnabled = true
        tableView.reloadData()
    }
    
}
extension SelectedFriendsListFromContact:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedFriends.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friends") as? SelectedFriendsListCell
        guard let cell = cell else{
            print("*** Error: while unwrapping cell @ friendslistVCForSplit")
            return UITableViewCell()
        }
        cell.setNameLable(with: selectedFriends[indexPath.row].name)
        cell.setPhoneNumberLabel(with: selectedFriends[indexPath.row].telephone)
        cell.removeFriendsFromSelectedFreindsDelegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func deleteFriendButtonDidTapped(_ button:UIButton){
        let deselected =  selectedFriends[button.tag].identifier
        totalRowSelected.removeAll(where: {$0 == deselected})
        selectedFriends.removeAll(where: {$0.identifier == deselected})
        showFriendsDelegate?.updateFriends(list: selectedFriends)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       
        let action = UIContextualAction(style: .destructive, title: "Delete") {_,_,completion in
            guard let cell = self.tableView.cellForRow(at: indexPath) as? SelectedFriendsListCell else{
                return
            }
            cell.deleteButtonDidTapped()
            completion(true)
        }
        let swipe =  UISwipeActionsConfiguration(actions: [action])
        return swipe
    }
}


extension SelectedFriendsListFromContact:UIAdaptivePresentationControllerDelegate{
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        cancelButtonDidTapped()
    }
}
extension SelectedFriendsListFromContact:RemoveFriendsFromSelectedFreindsDelegate{
    func removeFriend(at cell: UITableViewCell) {
        if let index = tableView.indexPath(for: cell) {
            let deselected =  selectedFriends[index.row].identifier
            totalRowSelected.removeAll(where: {$0 == deselected})
            selectedFriends.removeAll(where: {$0.identifier == deselected})
            showFriendsDelegate?.updateFriends(list: selectedFriends)
            tableView.deleteRows(at: [index], with: .automatic)
            
        }else{
            print("***Error cell not found")
        }
    }
}
