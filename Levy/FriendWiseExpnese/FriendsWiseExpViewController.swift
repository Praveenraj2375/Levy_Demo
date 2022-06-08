//
//  FriendsWiseExpViewController.swift
//  Levy
//
//  Created by Praveenraj T on 21/03/22.
//

import UIKit

protocol UpdateFriendsWiseExpDelegate{
    func updateFriendsWiseExp(newShare:Double)
}

class FriendsWiseExpViewController: UIViewController {
    
    let tripDetailFetchDelegate:TripDetailDBDelegate = UseCase()
    let entriesCountDelegate:EntriesCountDelegate = UseCase()
    let settleUpFromFreindWiseExpDelegate: SettleUpFromFreindWiseExpDelegate = UseCase()
    let SearchResultFromDBDelegate:SearchResultFromDBDelegate = UseCase()
    let totalReturnDelgate:TotalReturnDelegate = UseCase()
    let deleteFriendsDetailDelegate:DeleteFriendDetailDelegate = UseCase()
    let tripDetailDBDelegate : TripDetailDBDelegate = UseCase()

    
    static let cellIdentifier = "cell"
    var amountNeedsToBePaid = Double()
    
    var friendsWiseExpListData = [FriendWiseExpense]()
    var filterredData = [FriendWiseExpense]()
    
    var indexedFriendsListDetails = [String:[FriendWiseExpense]]()
    var indexName = [String]()
    var sortKey = SortViewController.nameAse
    
    var dataOffset = Int(0)
    let dataLimit = Int(7)
    var totalEntries = Int(0)
    var totalSearchResultEntries = Int(0)
    
    weak var actionToEnable : UIAlertAction?
    
    lazy var tableView:UITableView = {
        var tableView = UITableView(frame: CGRect(), style:  .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .secondarySystemBackground
        tableView.keyboardDismissMode = .onDrag
        tableView.refreshControl = refreshControl
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = .zero
        }
        return tableView
    }()
    
    var searchController:UISearchController = {
        let searchCont = UISearchController()
        searchCont.searchBar.autocapitalizationType = .none
        searchCont.searchBar.placeholder = "Search  Friends"
        
        searchCont.searchBar.searchTextField.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        return searchCont
        
    }()
    
    let containerView = UIView()
    
    let sortButton:UIButton = {
        let button = UIButton(type: .detailDisclosure)
        let image = UIImage(named: "sortIcon1.png")
        button.setImage(image, for: .normal)
        button.setTitle("Sort", for: .normal)
        return button
    }()
    
    let totalLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let showMoreButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show More...", for: .normal)
        return button
    }()
    
    lazy var footerView:UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var emptyTableView:ViewForEmptyTableview = {
        let view = ViewForEmptyTableview()
        view.actionButton.isEnabled = false
        view.actionButton.isHidden = true
        view.primaryLabel.text = "No friends added"
        view.secondaryLabel.text = "Friends linked with a Trip/Group will be shown here"
        return view
    }()
    
    lazy var refreshControl:UIRefreshControl = {
        let refersher = UIRefreshControl()
        refersher.attributedTitle = NSAttributedString(string: "Refresh")
        refersher.addTarget(self, action: #selector(refershData), for: .valueChanged)
        return refersher
    }()
        
    @objc func refershData(){
        self.refreshControl.endRefreshing()
        print("\n\n****")
        dataOffset = 0
        bringDataForUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureTableView()
        configureContainerView()
        configureSortButton()
        configureTotalLabel()
        configureSearchController()
        configureFooterView()
        bringDataForUI()
        configureUIWhileKeyBoardAppearing()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertSymbolDidTapped))
        
        NotificationCenter.default.addObserver(self, selector: #selector(newFreindsDidAdded(_ :)), name: .newFriendDidAdded, object: nil)
    }
    
    @objc func newFreindsDidAdded(_ notification:Notification){
        guard let friends = notification.userInfo?[UserInfoKeys.newFriend] as? [ContactDetail] else{
            return
        }
        for friend in friends {
            addNewFriend(from: friend)
        }
        
        dataOffset = 0
        bringDataForUI()
        
    }
    
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
        
    }
    
    @objc func insertSymbolDidTapped(){
        let contactPicker = customContactPicker(maxNumberOfNewFriends: 5)
        contactPicker.title = "Add Friends "
        present(UINavigationController(rootViewController: contactPicker),animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func  configureUIWhileKeyBoardAppearing(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func bringDataForUI() {
        if let value = userDefaults?.value(forKey: "friendsSortKey") as? String{
            sortKey = value
        }
        totalEntries = entriesCountDelegate.getEntriesCountInFriendsWiseExpTable()
        
        if totalEntries > friendsWiseExpListData.count && dataOffset > totalEntries{
            dataOffset = friendsWiseExpListData.count-1
        }
        if isNewTripAdded || isExpenseUpdated || isNewFriendAddedOrRemoved{
            dataOffset = 0
            isNewTripAdded = false
            isExpenseUpdated = false
            isNewFriendAddedOrRemoved = false
        }
        
        if dataOffset == 0{
            if !searchController.isActive{
                friendsWiseExpListData = []
                friendsWiseExpListData = tripDetailFetchDelegate.getEntireFriendWiseExpenseFromDB(limit: dataLimit, offset: dataOffset, sortBy: sortKey)

                if totalEntries != 0 &&  (totalEntries > friendsWiseExpListData.count || totalSearchResultEntries == filterredData.count){
                    tableView.tableFooterView = footerView
                }else{
                    tableView.tableFooterView = nil
                }
            }
        }else{
            if totalEntries == friendsWiseExpListData.count ||
                (totalSearchResultEntries == filterredData.count &&
                 totalSearchResultEntries != 0){
                print("No new request")
                tableView.tableFooterView = nil
            }else{
                if searchController.isActive{
                    let (entries,data) =  SearchResultFromDBDelegate.searchInFriendWiseTabel(
                        for: searchController.searchBar.text ?? "",
                        dataLimit: dataLimit,
                        dataOffset: dataOffset)
                    
                    totalSearchResultEntries = entries
                    filterredData.append(contentsOf:data)
                    
                    if totalSearchResultEntries > filterredData.count{
                        tableView.tableFooterView = footerView
                    }else{
                        tableView.tableFooterView = nil
                    }
                    tableView.reloadData()
                    return
                }else{
                    friendsWiseExpListData.append(contentsOf: tripDetailFetchDelegate.getEntireFriendWiseExpenseFromDB(limit: dataLimit, offset: dataOffset, sortBy: sortKey))
                    if totalEntries > friendsWiseExpListData.count{
                        tableView.tableFooterView = footerView
                    }
                    else{
                        tableView.tableFooterView = nil
                    }
                }
            }
        }
        
        splitDataIntoSections()
        updateSearchResults(for: searchController)
        updateTotalReturn()
        setFooterView()
        tableView.reloadData()
    }
    
    func setFooterView(){
        if filterredData.isEmpty{
            if totalEntries > friendsWiseExpListData.count{
                tableView.tableFooterView = footerView
            }
            else{
                tableView.tableFooterView = nil
            }
        }else{
            if totalSearchResultEntries > filterredData.count{
                tableView.tableFooterView = footerView
            }
            else{
                tableView.tableFooterView = nil
            }
        }
    }
    
    func updateTotalReturn(){
        let sum = totalReturnDelgate.getTotalReturn()
        if sum >= 0{
            totalLabel.text = "Amount To Be Received "+(currencyFormatter().string(from: sum as NSNumber) ?? " ")
            totalLabel.textColor = .systemGreen
        }else{
            totalLabel.text = "Amount To Be Paid "+(currencyFormatter().string(from: sum.magnitude as NSNumber) ?? " ")
            totalLabel.textColor = .systemRed
        }
    }
    
    func configureSearchController(){
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func configureContainerView(){
        tableView.addSubview(containerView)
        containerView.backgroundColor = .systemBackground
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 40)  ])
    }
    
    func configureFooterView(){
        footerView.addSubview(showMoreButton)
        showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showMoreButton.topAnchor.constraint(equalTo: footerView.topAnchor),
            showMoreButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor),
            showMoreButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor)
        ])
        
        showMoreButton.addTarget(self, action: #selector(showMoreButtonDidTapped), for: .touchUpInside)
        footerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 50)
        if totalEntries > friendsWiseExpListData.count{
            tableView.tableFooterView = footerView
        }
    }
    
    @objc func showMoreButtonDidTapped(){
        dataOffset += dataLimit
        bringDataForUI()
        if totalEntries == friendsWiseExpListData.count || (totalSearchResultEntries == filterredData.count && totalSearchResultEntries != 0){
            tableView.tableFooterView = nil
        }
        return
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
        
        tableView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        
        tableView.register(ExpesenceDetailCell.self, forCellReuseIdentifier: FriendsWiseExpViewController.cellIdentifier)
        tableView.separatorStyle = .none
        tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        
        
    }
    
    func configureSortButton(){
        containerView.addSubview(sortButton)
        
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sortButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            sortButton.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
        sortButton.addTarget(self, action: #selector(sortButtonDidTapped), for: .touchUpInside)
    }
    
    @objc func sortButtonDidTapped(){
        let sortVCPresenter = SortVCPresenter(selectedKey: sortKey,options: [SortVCPresenter.nameRow,SortVCPresenter.amountRow])
        sortVCPresenter.sortTripListDelegate = self
        sortVCPresenter.updateViewTransparencyDelegate = self
        
        let sortvc =  SortViewController(presenter: sortVCPresenter)
        sortvc.title = "Sort"
        let navCont = UINavigationController(rootViewController: sortvc)
        navCont.modalPresentationStyle = .pageSheet
        
        if #available(iOS 15.0, *) {
            navCont.sheetPresentationController?.detents = [.medium()]
        }
        
        present(navCont, animated: true, completion: nil)
        view.alpha = 0.2

    }
    
    @objc func sortVCEmptySpaceDidTapped(){
        presentedViewController?.dismiss(animated: true)
        view.alpha = 1
    }
    
    func configureTotalLabel(){
        containerView.addSubview(totalLabel)
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalLabel.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 10),
            totalLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            totalLabel.trailingAnchor.constraint(lessThanOrEqualTo: sortButton.leadingAnchor, constant: -10)
        ])
    }
    
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.tableView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 10
        tableView.contentInset = contentInset
        
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        tableView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
    }
    
    
    func hideSearchBar(){
        navigationItem.searchController = nil
        navigationController?.navigationBar.layoutIfNeeded()

    }
    
    func showSearchBar(){
        navigationItem.searchController = searchController
        navigationController?.navigationBar.layoutIfNeeded()
    }
    
    func hideSortButton(){
        sortButton.isHidden = true
        sortButton.isEnabled = false
    }
    
    func showSortButton(){
        sortButton.isEnabled = true
        sortButton.isHidden = false
    }
    
}

extension FriendsWiseExpViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if filterredData.count == 0{
            if indexName.count == 0{
                tableView.backgroundView = emptyTableView
                hideSortButton()
                hideSearchBar()
                return 0
            }
            showSearchBar()
            
            return indexName.count
        }else{
            sortButton.isEnabled = false
            sortButton.isHidden = true
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = nil

        if filterredData.isEmpty{
            if searchController.isActive && searchController.searchBar.text != ""{
                Levy.emptySearchResult(for: tableView, in: view)
                sortButton.isEnabled = false
                sortButton.isHidden = true
                return 0
            }
            else{
                tableView.backgroundView = nil
            }
            
            if friendsWiseExpListData.count == 0{
                tableView.backgroundView = emptyTableView
                sortButton.isHidden = true
                sortButton.isEnabled = false
                return 0
            }
            else{
                tableView.backgroundView = nil
                
                let key = indexName[section]
                sortButton.isHidden = false
                sortButton.isEnabled = true
                return indexedFriendsListDetails[key]?.count ?? 0
            }
        }
        else{
            
            return filterredData.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchController.isActive && searchController.searchBar.text != ""{
            return .zero
        }
       return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let friendDetail = indexedFriendsListDetails[indexName[indexPath.section]] else{
            return UITableViewCell()
        }
        var  friendDetailForIndex = friendDetail
        if !filterredData.isEmpty{
            friendDetailForIndex = []
            friendDetailForIndex.append(contentsOf: filterredData)
            if indexPath.row == filterredData.count{
                let cell = UITableViewCell()
                cell.textLabel?.text = "show more ..."
                return cell
            }
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendsWiseExpViewController.cellIdentifier) as! ExpesenceDetailCell
        cell.setTitlelabel(with: friendDetailForIndex[indexPath.row].name)
        cell.bottomLeftButton.setTitle(friendDetailForIndex[indexPath.row].phoneNumber, for: .normal)
        
        cell.configureButtonContent()
        cell.settleupButtonDelegate = self

        cell.setTopRightLable(with: friendDetailForIndex[indexPath.row].totalReturn)
        
        if friendDetailForIndex[indexPath.row].totalReturn == 0{
            cell.settleUpButton.isEnabled = false
            cell.settleUpButton.isHidden = true
            cell.settleUpButtonHeightAnchor.isActive = false
            cell.settleUpButtonZeroHeight.isActive = true
            cell.topRightLabelCenterYAnchor.isActive = true
        }
        else{
            cell.settleUpButton.isEnabled = true
            cell.settleUpButton.isHidden = false
            cell.settleUpButtonZeroHeight.isActive = false
            cell.topRightLabelCenterYAnchor.isActive = false
            cell.settleUpButtonHeightAnchor.isActive = true

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        var sectionwiseData = [FriendWiseExpense]()
        if filterredData.count == 0{
            let key = indexName[indexPath.section]
            sectionwiseData.append(contentsOf:  indexedFriendsListDetails[key] ?? [])
        }
        else{
            sectionwiseData.append(contentsOf: filterredData)
            
        }
        
        let friendWiseDetailVC = FriendWiseExpDetailedVC(friend: sectionwiseData[indexPath.row])
        friendWiseDetailVC.title = sectionwiseData[indexPath.row].name
        friendWiseDetailVC.refresherForFriendWiseExpenseDelegate = self
        navigationController?.pushViewController(friendWiseDetailVC, animated: true)
    }
   
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       
        var isHaveDues = false
        var friendIDForDeletion = String()
        let index = self.indexName[indexPath.section]
        
        if self.filterredData.count != 0 {
            friendIDForDeletion = filterredData[indexPath.row].friendID

            if self.filterredData[indexPath.row].totalReturn != 0{
               isHaveDues = true
            }
        }else{
            
            friendIDForDeletion = indexedFriendsListDetails[index]?[indexPath.row].friendID ?? "0"
            if self.indexedFriendsListDetails[index]?[indexPath.row].totalReturn != 0{
               isHaveDues = true

            }
        }
        
        
        let alert = UIAlertController(title: "⚠ Warning", message: "Are you sure want to remove friend detail permanently ?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style:.destructive , handler: {_ in
            self.deleteFriendsDetailDelegate.deleteFriendDetail(for: friendIDForDeletion)
            if self.filterredData.isEmpty{
                self.friendsWiseExpListData.removeAll(where: {$0.friendID == self.indexedFriendsListDetails[index]?[indexPath.row].friendID})
                self.indexedFriendsListDetails[index]?.removeAll(where: {$0.friendID == friendIDForDeletion})
                tableView.deleteRows(at: [indexPath], with: .automatic)

                if self.indexedFriendsListDetails[index]?.isEmpty == true{
                    self.indexedFriendsListDetails[index] = nil
                    self.indexName.removeAll(where: {$0 == index})
                    self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                    self.tableView.layoutIfNeeded()

                }
            }else{
                self.friendsWiseExpListData.removeAll(where: {$0.friendID == self.filterredData[indexPath.row].friendID})
                self.filterredData.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            self.bringDataForUI()
            isNewFriendAddedOrRemoved = true
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
            throwWarningToUser(viewController: self, title: "⚠ Error", errorMessage: "Friend is not cleared his/her dues yet.Please clear all dues before deletion..")
                completion(true)
                return
            }
            
            self.present(alert, animated: true, completion: nil)
            completion(true)
        }
        let swipe =  UISwipeActionsConfiguration(actions: [action])
        return swipe
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        tableView.bringSubviewToFront(containerView)
    }
}
extension FriendsWiseExpViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxCharacterInTextField = InsertExpenseViewController.ExpenseAmountCharecterLimit + 3
        
        guard let currentText = textField.text as NSString? else{
            return true
        }
        
        let replacementString = currentText.replacingCharacters(in: range, with: string)
        let allowedCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: Locale.current.decimalSeparator ?? "."))
        let characterSet = CharacterSet(charactersIn: string)
        let isNumeric = allowedCharacters.isSuperset(of: characterSet)
        
        guard let paid = Double(replacementString) else{
            if replacementString == ""{
                return true
            }
            throwWarningToUser(viewController: self.presentedViewController ?? self, title: "Error", errorMessage: "You are tring to enter Invalid number \'\(replacementString)\'")
            return false
        }
        
        guard let currency = Locale.current.currencySymbol else{
            return true
        }
        
        if paid > amountNeedsToBePaid{
            throwWarningToUser(viewController: self.presentedViewController ?? self, title: "Error", errorMessage: "Settled amount not more than total amount to be paid/received\nSettleup amount =  \(currency) \(amountNeedsToBePaid)")
            return false
        }
        return (replacementString.count <= maxCharacterInTextField) && isNumeric
    }
    
}
extension FriendsWiseExpViewController:RefresherForFriendWiseExpenseDelegate{
    func refreshData() {
        self.bringDataForUI()
    }
}


extension FriendsWiseExpViewController{

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if searchController.isActive && (searchController.searchBar.text != ""){
            return nil
        }
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")as? HeaderView
        guard let header = header else{
            print("***Error while unwrapping header view")
            return UITableViewHeaderFooterView()
        }
        
        if filterredData.isEmpty{
            if indexName.count == 0{
                return nil
            }
            header.titleLabel.text =  indexName[section]}
        else{
            header.titleLabel.text = nil
        }
        return header
    }
    
}

extension FriendsWiseExpViewController:UISearchResultsUpdating,UISearchBarDelegate{
    func updateSearchResults(for searchController: UISearchController) {
        if !self.searchController.isActive{
            return
        }
        filterredData = []
        totalSearchResultEntries = 0
        dataOffset = 0
        
        guard let text = searchController.searchBar.text?.lowercased() else{
            return
        }
        
        if text == ""{
            tableView.reloadData()
            return
        }
        
        (totalSearchResultEntries,filterredData) = SearchResultFromDBDelegate.searchInFriendWiseTabel(for: text, dataLimit: dataLimit, dataOffset: dataOffset)
        if totalSearchResultEntries > filterredData.count{
            tableView.tableFooterView = footerView
        }else{
            tableView.tableFooterView = nil
        }
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
        filterredData = []
        totalSearchResultEntries = 0
        dataOffset = 0
        bringDataForUI()
    }
    
}

extension FriendsWiseExpViewController:UISheetPresentationControllerDelegate{
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        view.alpha = 1
    }

}

extension FriendsWiseExpViewController{
    func splitDataIntoSections(){
        switch sortKey{
        case SortViewController.nameAse,SortViewController.nameDesc:sortByName()
        case SortViewController.amountAsc,SortViewController.amountDesc : sortByAmount()
        default: sortByName()
        }
    }
    
    func sortByName(){
        var groupUsingDictionary = Dictionary(grouping: self.friendsWiseExpListData) { (friend) -> String  in
            guard let first = friend.name.first?.uppercased() else{
                return " "
            }
            return String(first)
        }
        var keys = [String]()
        
        if sortKey == SortViewController.nameAse{
            keys = groupUsingDictionary.keys.sorted(by: { $0.uppercased() < $1.uppercased() })
        }else{
            keys = groupUsingDictionary.keys.sorted(by: { $0.uppercased() > $1.uppercased() })
        }
        for key in keys{
            if sortKey == SortViewController.nameAse{
                groupUsingDictionary[key]?.sort(by: {$0.name.lowercased() < $1.name.lowercased()})
            }else{
                groupUsingDictionary[key]?.sort(by: {$0.name.lowercased() > $1.name.lowercased()})
            }
        }
        indexName = keys
        indexedFriendsListDetails = groupUsingDictionary
    }
    
    func sortByAmount(){
        var keys = [String]()
        var groupUsingKey = [String:[FriendWiseExpense]]()
        let needsToBePaid = "Needs To Be Paid"
        let toBeReceived = "To Be Received"
        let allSetteled = "All Setteled"
        
        for friend in friendsWiseExpListData{
            
            switch friend.totalReturn{
            case let x where x < 0: groupUsingKey[needsToBePaid,default: []].append(friend)
            case let x where x > 0: groupUsingKey[toBeReceived,default: []].append(friend)
            case let x where x == 0 : groupUsingKey[allSetteled,default: []].append(friend)
            default: continue
            }
            
        }
        
        if sortKey == SortViewController.amountAsc{
            keys = [needsToBePaid,toBeReceived,allSetteled]
            
            for key in keys{
                if groupUsingKey[key]?.count == nil{
                    keys.removeAll(where: {$0 == key})
                    continue
                }
                
                groupUsingKey[key]?.sort(by: {trip1,trip2 in
                    if trip1.totalReturn == trip2.totalReturn{
                        return  trip1.name < trip2.name
                    }else{
                        return trip1.totalReturn.magnitude < trip2.totalReturn.magnitude
                    }
                })
            }
        }else{
            keys = [toBeReceived,needsToBePaid,allSetteled]
            for key in keys{
                if groupUsingKey[key]?.count == nil{
                    keys.removeAll(where: {$0 == key})
                    continue
                }
                groupUsingKey[key]?.sort(by: {fr1,fr2 in
                    if fr1.totalReturn == fr2.totalReturn{
                        return fr1.name < fr2.name
                    }else{
                        return fr1.totalReturn.magnitude > fr2.totalReturn.magnitude
                    }
                })
            }
        }
        
        indexedFriendsListDetails = groupUsingKey
        indexName = keys
    }
}

extension FriendsWiseExpViewController:SortTripListDelegate,UpdateViewTransparencyDelegate{
    func updateAlpha() {
        view.alpha = 1

    }
    func updateSortKey(key: String) {
        self.view.alpha = 1
        dataOffset = 0
        sortKey = key
        view.alpha = 1
        userDefaults?.setValue(sortKey, forKey: "friendsSortKey")
        //tableView.contentOffset = CGPoint(x: 0, y: 30)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at:.top, animated: true)
        tableView.layoutIfNeeded()
        bringDataForUI()
    }
}

extension FriendsWiseExpViewController:SettleupButtonDelegate{
    
    @objc func textChanged(_ sender:UITextField) {
        self.actionToEnable?.isEnabled  = (sender.text! != "")
    }
    
    func settleupButtonDidTappd(at cell:UITableViewCell) {
        guard let tappedIndex = tableView.indexPath(for: cell) else{
            print("Error-cell not found")
            return
        }
        let alert = UIAlertController(title: "", message: "Enter Settle Amount", preferredStyle: .alert)
       
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        var tapped :FriendWiseExpense?

        if filterredData.isEmpty{
            guard let tappedFromSection = (indexedFriendsListDetails[indexName[tappedIndex.section]])?[tappedIndex.row] else{
                print("***Error while finding the indexed trip")
                return
            }
            tapped = tappedFromSection
        }
        else{
            tapped = filterredData[tappedIndex.row]
        }
        
        guard let tapped = tapped else {
            return
        }
        amountNeedsToBePaid = tapped.totalReturn.magnitude
        alert.addTextField(configurationHandler: {newText in
            newText.placeholder = "Enter settle Up Amount"
            newText.keyboardType = .decimalPad
            newText.delegate = self
            newText.text = self.amountNeedsToBePaid.description
            newText.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
        })
        let okAction = UIAlertAction(title: "OK", style: .default,handler: { [self]_ in
            alert.textFields?.first?.resignFirstResponder()
            guard let amountText =  alert.textFields?.first?.text else{
                return
            }
            let formatter = NumberFormatter()
            formatter.decimalSeparator = Locale.current.decimalSeparator
            
            guard let paidAmount = formatter.number(from: amountText) as? Double else{
                return
            }
            
            
            guard let index = friendsWiseExpListData.firstIndex(where:  {$0.friendID == tapped.friendID}) else{
                print("***Error while unwrapping index@friendwiseExp")
                return
            }
            
            if friendsWiseExpListData[index].totalReturn.magnitude == paidAmount {
                self.settleUpFromFreindWiseExpDelegate.settledFully(friendID: friendsWiseExpListData[index].friendID)
                self.friendsWiseExpListData[index].totalReturn = 0
                if !filterredData.isEmpty{
                    filterredData[tappedIndex.row].totalReturn = 0
                }
                self.tableView.reloadRows(at: [tappedIndex], with: .automatic)
                
            }
            else if friendsWiseExpListData[index].totalReturn.magnitude > paidAmount{
                if friendsWiseExpListData[index].totalReturn > 0{
                    settleUpFromFreindWiseExpDelegate.settledPartialAmount(frindID: friendsWiseExpListData[index].friendID, paidAmount: paidAmount)
                }
                else {
                    settleUpFromFreindWiseExpDelegate.settledPartialAmount(frindID: friendsWiseExpListData[index].friendID, paidAmount: -paidAmount)
                }
                isExpenseUpdated = true
            }
            bringDataForUI()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        self.actionToEnable = okAction
        //okAction.isEnabled = false
        alert.preferredAction = okAction

        present(alert,animated: true)

    }
}
