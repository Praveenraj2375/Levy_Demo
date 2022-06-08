//
//  customPIcker.swift
//  customContactPIcker
//
//  Created by Praveenraj T on 18/04/22.
//

import UIKit
import Contacts
import ContactsUI


protocol UpdateFriendsDelegate:AnyObject{
    func updateFriends(friends:[ContactDetail])
}

class customContactPicker:UITableViewController,CNContactViewControllerDelegate {
    
    weak var updateFriendsDelegate:UpdateFriendsDelegate?
    let appSpcificContactDelegate:AppSpcificContactDelegate = UseCase()
    
    var totalContacts = [ContactDetail]()
    var searchResult = [ContactDetail]()
    var selectedContacts = [ContactDetail]()
    var preSelectedArrayOfIdentifier = [String]()
    var previousSearchText = ""
    
    var arrayOfId = [String]()
    var maxContactSelct = Int(10)
    var isProgramaticSelection = false
    lazy var appContacts = appSpcificContactDelegate.readFromFriendWiseExpTable(existedID: self.preSelectedArrayOfIdentifier)
    
    let containerView = UIView()
    var searchController:UISearchController = {
        let searchCont = UISearchController()
        searchCont.searchBar.autocapitalizationType = .none
        searchCont.hidesNavigationBarDuringPresentation = false
        searchCont.searchBar.placeholder = "Search Contact "

        return searchCont
        
    }()
    
    var addContactButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add New Contact", for: .normal)
        button.setImage(UIImage(systemName: "person.crop.circle.badge.plus"), for: .normal)
        
        
        if #available(iOS 15.0, *){
            var config = UIButton.Configuration.borderless()
            config.imagePlacement = .trailing
            config.imagePadding = 10
            button.configuration = config
        }else{
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        }
        return button
    }()
    
    lazy var emptyTableView:ViewForEmptyTableview = {
        let view = ViewForEmptyTableview()
        view.actionButton.isHidden = true
        view.actionButton.isEnabled = false
        view.primaryLabel.text = "No contacts found or all contacts are linked"
       
        return view
    }()
    
    
    init(){
        maxContactSelct = 10
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(maxNumberOfNewFriends:Int){
        let friendID:FriendIDDelegate = UseCase()
        preSelectedArrayOfIdentifier.append(contentsOf: friendID.getFriendsID())
        maxContactSelct = preSelectedArrayOfIdentifier.count + maxNumberOfNewFriends
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true

        tableView.dataSource = self
        tableView.delegate = self
        
        configureTableView()
        fetchContacts()
        configureConteinerView()
        configureAddContactButton()
        configureSearchController()
        configureNavigationBar()
        
    }
    
    func configureTableView(){
        
        tableView.register(ContactStoreListCell.self, forCellReuseIdentifier: ContactStoreListCell.identifier)
        tableView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        tableView.allowsMultipleSelection = true
    }
    
    func configureNavigationBar(){
        navigationController?.presentationController?.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonDidTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidTapped))
    }
    
    func configureConteinerView(){
        tableView.addSubview(containerView)
        containerView.backgroundColor = .systemBackground
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.leadingAnchor,constant: 10),
            containerView.trailingAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            containerView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    
    func configureAddContactButton(){
        containerView.addSubview(addContactButton)
        
        addContactButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addContactButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            addContactButton.leadingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 10),
            addContactButton.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            addContactButton.trailingAnchor.constraint(greaterThanOrEqualTo: tableView.trailingAnchor,constant: -10),
            addContactButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        addContactButton.addTarget(self, action: #selector(addContactButtonDidTapped), for: .touchUpInside)
    }
    
    func configureSearchController(){
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
    }
    
    @objc func addContactButtonDidTapped(){
        let newContactVC = NewContactViewController()
        newContactVC.title = "New Contact"
        newContactVC.newContactDelegate = self
        present(UINavigationController(rootViewController: newContactVC),animated: true)
    }
    
    @objc func doneButtonDidTapped(){
        searchController.dismiss(animated: true)
        isNewFriendAddedOrRemoved = true
        updateFriendsDelegate?.updateFriends(friends: selectedContacts)
        NotificationCenter.default.post(name: .newFriendDidAdded, object: nil,userInfo: [UserInfoKeys.newFriend:selectedContacts])
        dismiss(animated: true)
    }
    
    @objc func cancelButtonDidTapped(){
        if selectedContacts.isEmpty{
            searchController.dismiss(animated: true)
            dismiss(animated: true)
        }else{
            let alerSheet = UIAlertController(title: nil, message: "Are you sure you want to discard changes?", preferredStyle: .actionSheet)
            alerSheet.addAction(UIAlertAction(title: "Keep Editing", style: .cancel, handler: nil))
            alerSheet.addAction(UIAlertAction(title: "Discard Changes", style: .destructive, handler: {_ in
                self.searchController.dismiss(animated: true)
                self.dismiss(animated: true, completion: nil)
            }))
            alerSheet.popoverPresentationController?.sourceView = self.view
            let xOrigin = 0
            let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
            alerSheet.popoverPresentationController?.sourceRect = popoverRect
            alerSheet.popoverPresentationController?.permittedArrowDirections = .up
            present(alerSheet,animated: true)
        }
        
    }
    
    
    private func fetchContacts() {
        self.totalContacts.append(contentsOf: self.appContacts)
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (isGranted, error) in
            if let error = error {
                print("failed to request access\n",error)
                
                DispatchQueue.main.async {
                    let emptyTable = ViewForEmptyTableview()
                    emptyTable.actionButton.setTitle("Open Setting", for: .normal)
                    emptyTable.primaryLabel.text = "Please allow access to contanct to view contact details"
                    emptyTable.actionButton.addTarget(self, action: #selector(self.allowContactAccessButtonDidTapped), for: .touchUpInside)
                    self.tableView.backgroundView = emptyTable
                }
                return
            }
            
            if isGranted {
                let keys = [CNContactIdentifierKey,CNContactGivenNameKey,CNContactMiddleNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                do {
                    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                    
                    var contactCount = Int(0)
                    var fetchedBatch = [ContactDetail]()
                    try store.enumerateContacts(with: request, usingBlock: { (contact, _) in
                        
                        if self.preSelectedArrayOfIdentifier.contains( contact.identifier) || contact.phoneNumbers.first == nil {
                            return
                        }else{
                            fetchedBatch.append(ContactDetail(identifier: contact.identifier,name:  contact.givenName + " " + contact.middleName + " " + contact.familyName, telephone: contact.phoneNumbers.first?.value.stringValue ?? ""))
                            contactCount += 1
                        }
                        if  contactCount % 100 == 0{
                            self.updateTableView(data:fetchedBatch)
                            fetchedBatch = []
                        }
                    })
                    self.updateTableView(data: fetchedBatch)
                } catch  {
                    print("Failed to fetch contact", error)}
            } else {
                print("access denied")}
        }
    }
    
    
    
    func updateTableView(data:[ContactDetail]){
        DispatchQueue.main.async {
            self.totalContacts.append(contentsOf: data)
            self.totalContacts.sort(by: {$0.name < $1.name})
            self.tableView.backgroundView = nil
            self.tableView.reloadData()
        }
    }
    
    @objc func allowContactAccessButtonDidTapped(){
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            print(settingsUrl)
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler:nil)
            }
        }
    }
}

extension customContactPicker{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchResult.isEmpty{
            if searchController.isActive && searchController.searchBar.text != ""{
                emptyTableView.primaryLabel.text = "No Contact Found"
                emptyTableView.secondaryLabel.text = nil
                tableView.backgroundView = emptyTableView
                return 0
            }else{
                tableView.backgroundView = nil
            }
            if totalContacts.count == 0{
                emptyTableView.primaryLabel.text = "No contacts found or all contacts are linked with trip or group"
                emptyTableView.secondaryLabel.text = ""
                tableView.backgroundView = emptyTableView
                return 0
            }
            tableView.backgroundView = nil
            return totalContacts.count
        }else{
            tableView.backgroundView = nil
            return searchResult.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactStoreListCell.identifier) as? ContactStoreListCell else{
            return UITableViewCell()
        }
        
        if searchResult.isEmpty{
            cell.friendNameLabel.text = totalContacts[indexPath.row].name
            cell.phoneNumberLabel.text = totalContacts[indexPath.row].telephone
            if selectedContacts.contains(where: {$0.identifier == self.totalContacts[indexPath.row].identifier}){
                cell.accessoryType = .checkmark
                cell.isSelected = true
            }else{
                cell.accessoryType = .none
                cell.isSelected = false
            }
        }else{
            cell.friendNameLabel.text = searchResult[indexPath.row].name
            cell.phoneNumberLabel.text = searchResult[indexPath.row].telephone
            if selectedContacts.contains(where: {$0.identifier == self.searchResult[indexPath.row].identifier}){
                cell.accessoryType = .checkmark
                cell.isSelected = true
            }else{
                cell.accessoryType = .none
                cell.isSelected = false
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ContactStoreListCell else{
            return
        }
        if cell.accessoryType != .none && !isProgramaticSelection{
            self.tableView(tableView, didDeselectRowAt: indexPath)
            return
        }
        
        if !isProgramaticSelection {
            if   (preSelectedArrayOfIdentifier.count+arrayOfId.count) >= maxContactSelct{
                tableView.deselectRow(at: indexPath, animated: false)
                throwWarningToUser(viewController: self, title: "Error", errorMessage: "Maximum member count reached")
                isProgramaticSelection = false
                
                return
            }
        }
        
        if !searchResult.isEmpty && !isProgramaticSelection{
            
            if (preSelectedArrayOfIdentifier.count+arrayOfId.count) >= maxContactSelct{
                tableView.deselectRow(at: indexPath, animated: false)
                isProgramaticSelection = false
                throwWarningToUser(viewController: self, title: "Error", errorMessage: "Maximum member count reached")
                return
            }
            
        }
        
        
        if searchResult.isEmpty{
            if !arrayOfId.contains(totalContacts[indexPath.row].identifier){
                arrayOfId.append(totalContacts[indexPath.row].identifier)
                selectedContacts.append(totalContacts[indexPath.row])
            }
            cell.accessoryType = .checkmark
            let selected = totalContacts.remove(at: indexPath.row)
            totalContacts.insert(selected, at: 0)
            tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
        }else{
            if !arrayOfId.contains(searchResult[indexPath.row].identifier){
                arrayOfId.append(searchResult[indexPath.row].identifier)
                selectedContacts.append(searchResult[indexPath.row])
            }
            cell.accessoryType = .checkmark
            
            let selected = searchResult.remove(at: indexPath.row)
            searchResult.insert(selected, at: 0)
            tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
        }
        tableView.bringSubviewToFront(containerView)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ContactStoreListCell else{
            print("Error while deslecting")
            return
        }
        var index = Int(0)
        if searchResult.isEmpty{
            arrayOfId.removeAll(where: {$0 == totalContacts[indexPath.row].identifier})
            selectedContacts.removeAll(where: {$0.identifier == totalContacts[indexPath.row].identifier})
            
            let deselected = totalContacts.remove(at: indexPath.row)
            for itemNumber in 0..<totalContacts.count{
                if itemNumber < arrayOfId.count{
                    continue
                }
                else{
                    if totalContacts[itemNumber].name < deselected.name{
                        continue
                    }else{
                        index = itemNumber
                        break
                    }
                }
            }
            cell.accessoryType = .none
            totalContacts.insert(deselected, at: index)
            tableView.moveRow(at: indexPath, to: IndexPath(row: index, section: 0))
        }
        else{
            arrayOfId.removeAll(where: {$0 == searchResult[indexPath.row].identifier})
            selectedContacts.removeAll(where: {$0.identifier == searchResult[indexPath.row].identifier})
            
            let  deselected = searchResult.remove(at: indexPath.row)
            for itemNumber in 0..<searchResult.count{
                if itemNumber < arrayOfId.count{
                    continue
                }
                else{
                    if searchResult[itemNumber].name < deselected.name{
                        continue
                    }else{
                        index = itemNumber
                        break
                    }
                }
            }
            cell.accessoryType = .none
            
            searchResult.insert(deselected, at: index)
            tableView.moveRow(at: indexPath, to: IndexPath(row: index, section: 0))
        }
        tableView.bringSubviewToFront(containerView)
        
    }
}

extension customContactPicker:NewContactDelegate{
    func willAddFriend(friend: ContactDetail) {
        totalContacts.insert(friend, at: 0)
        //tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        tableView.reloadData()
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
        self.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        
        
    }
}


extension customContactPicker:UISearchResultsUpdating,UISearchBarDelegate{
    
    func updateSearchResults(for searchController: UISearchController) {
        searchResult = []
        if !searchController.isActive{
            return
        }
        guard let text = searchController.searchBar.text?.lowercased() else{
            return
        }
        
        if previousSearchText == text{
            return
        }
        
        if text == ""{
            tableView.reloadData()
            selectContacts(contacts: totalContacts)
            isProgramaticSelection = false
            previousSearchText = text
            return
        }
        
        totalContacts.forEach({
            contacts in
            if contacts.name.lowercased().contains(text) || contacts.telephone.contains(text)
            {
                self.searchResult.append( contacts)
            }
        })
        
        tableView.reloadData()
        selectContacts(contacts: searchResult)
        isProgramaticSelection = false
        previousSearchText = text
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResult = []
        if "" == searchBar.text{
            previousSearchText = ""
            return
        }
        searchBar.text = ""

        tableView.reloadData()
        selectContacts(contacts: totalContacts)
        isProgramaticSelection = false
        previousSearchText = ""

    }
    
    
    
    
    func selectContacts(contacts:[ContactDetail]){
        let ids = arrayOfId//.reversed()

        for id in ids{
            if let index = contacts.firstIndex(where: {$0.identifier == id}){
                
                isProgramaticSelection = true
                tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .top)
                self.tableView(tableView, didSelectRowAt: IndexPath(row: index, section: 0))
               // sleep(1)
            }
            else{
                print("contact not found \(selectedContacts.filter({$0.identifier == id}))")
            }
            
            
        }
    }
    
}
extension customContactPicker:UIAdaptivePresentationControllerDelegate{
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        cancelButtonDidTapped()
    }
}
