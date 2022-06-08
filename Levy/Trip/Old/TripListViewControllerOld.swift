//
//  TripListViewController.swift
//  Levy
//
//  Created by Praveenraj T on 08/03/22.
//

import UIKit

class TripListViewControllerOld: UIViewController, UINavigationControllerDelegate,UIGestureRecognizerDelegate {
    
    static let cellIdentifier = "tripCell"
    var sortKey = SortViewController.dateDesc
    var indexedTripDetail = [String:[TripDetails]]()
    var indexName = [String]()
    
    let delegate : TripListDelegate = UseCase()
    let entriesCountDelegate:EntriesCountDelegate = UseCase()
    let totalReturnDelgate:TotalReturnDelegate = UseCase()
    let SearchResultFromDBDelegate:SearchResultFromDBDelegate = UseCase()
    let deletionDelegate : DeleteTripDelegate = UseCase()
    
    var tripDetailListData = [TripDetails]()
    var filterredData = [TripDetails]()
    
    
    var dataOffset = Int(0)
    let defaultDataLimit = Int(7)
    var dataLimit = Int(7)
    var totalEntries = Int(0)
    var totalSearchResultEntries = Int(0)
    var previousSearchText  = ""
    
    let containerView = UIView()
    let tableView:UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .none
        table.backgroundColor = .secondarySystemBackground
        table.keyboardDismissMode = .onDrag
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = .zero
        } 
        return table
    }()
    
    var searchController:UISearchController = {
        let searchCont = UISearchController()
        searchCont.searchBar.autocapitalizationType = .none
        searchCont.searchBar.placeholder = "Search Trips"
        return searchCont
        
    }()
    
    var sortButton:UIButton = {
        let button = UIButton(type: .contactAdd)
        button.setTitle("Sort", for: .normal)
        let image = UIImage(named: "sortIcon1.png")
        button.setImage(image, for: .normal)
        return button
    }()
    
    
    let totalLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(UILayoutPriority(255), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
        return label
    }()
    
    lazy var emptyTableView:ViewForEmptyTableview = {
        let view = ViewForEmptyTableview()
        view.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        view.actionButton.setTitle("Start Trip", for: .normal)
        view.actionButton.addTarget(self, action: #selector(insertSymbolInTripVCDidTapped), for: .touchUpInside)
        view.primaryLabel.text = "No Trip Added"
        view.secondaryLabel.text = nil
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Trips"
        
        configureTableView()
        configureConteinerView()
        configureSortButton()
        configureTotalLabel()
        configureSearchController()
        bringDataForUI()
        configureUIWhileKeyBoardAppearing()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertSymbolInTripVCDidTapped))
        
    }
    

    override func bringDataForUI() {
        if let sortKeyValue = userDefaults?.value(forKey: userDefaults?.tripListSortKey ?? "") as? String{
        sortKey = sortKeyValue
        }
        
        totalEntries = entriesCountDelegate.getEntriesCountInTripListTable()
        
        if (totalEntries > tripDetailListData.count || totalSearchResultEntries > filterredData.count ) && dataOffset > totalEntries{
            if totalEntries != tripDetailListData.count{
            dataOffset = tripDetailListData.count - 1
            }
        }
        
        if isNewTripAdded || isExpenseUpdated || isNewFriendAddedOrRemoved{
            dataOffset = 0
            isNewTripAdded = false
            isExpenseUpdated = false
            isNewFriendAddedOrRemoved = false
        }
        
        if dataOffset == 0{
            if !searchController.isActive{
            tripDetailListData = []
                tripDetailListData.append(contentsOf:  delegate.getEntireTripListFromDB(limit: dataLimit, offset: dataOffset, sortBy: sortKey))
            }
        }else{
            if totalEntries == tripDetailListData.count || (totalSearchResultEntries == filterredData.count && totalSearchResultEntries != 0){
                print("No new request")
                return
            }else{
                if searchController.isActive{
                    let (entries,data) =  SearchResultFromDBDelegate.searchInTirpListTabel(for: searchController.searchBar.text ?? "", dataLimit: dataLimit, dataOffset: dataOffset)
                    totalSearchResultEntries = entries
                    filterredData.append(contentsOf:data)
                    tableView.reloadData()
                    
                    return
                }else{
                    tripDetailListData.append(contentsOf: delegate.getEntireTripListFromDB(limit: dataLimit, offset: dataOffset, sortBy: sortKey))
                }
            }
        }
        splitDataIntoSections()
        updateTotalLabelValue()
        tableView.reloadData()
    }
    
    func configureUIWhileKeyBoardAppearing(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func updateTotalLabelValue(){
        let sum = totalReturnDelgate.getTotalReturn()

        if sum >= 0{
            totalLabel.text = "Amount To Be Received "+(currencyFormatter().string(from: sum as NSNumber) ?? " ")
            totalLabel.textColor = .systemGreen
        }else{
            totalLabel.text = "Amount To Be Paid "+(currencyFormatter().string(from: sum.magnitude as NSNumber) ?? " ")
            totalLabel.textColor = .systemRed
        }
    }
    
    func configureConteinerView(){
        tableView.addSubview(containerView)

        containerView.backgroundColor = .systemBackground
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    
    func configureSortButton(){
        containerView.addSubview(sortButton)
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sortButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            sortButton.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
        sortButton.addTarget(self, action: #selector(sortButtonDidTapped), for: .touchUpInside)
    }

    @objc func sortButtonDidTapped(){
        let sortvc =  SortViewController(selectedKey: sortKey)
       
//        sortvc.configureDateLabel()
//        sortvc.configureDateSegmentButton()
//        sortvc.nameLabelTopAnchor.isActive = true
//        sortvc.nameSegmentTopAnchor.isActive = true
        sortvc.title = "Sort Order"
        sortvc.sortTripListDelegate = self
        sortvc.updateViewTransparencyDelegate = self
        let navCont = UINavigationController(rootViewController: sortvc)
        navCont.modalPresentationStyle = .pageSheet
        navCont.presentationController?.delegate = self
        if #available(iOS 15.0, *) {
            navCont.sheetPresentationController?.detents = [.medium()]
        }
        
        present(navCont, animated: true, completion: nil)
        view.alpha = 0.2

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
    
    func configureSearchController(){
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
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
        
        tableView.register(TripListCell.self, forCellReuseIdentifier: TripListCell.identifier)
        tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderView.identifier)
    }
    
    @objc func insertSymbolInTripVCDidTapped(){
        
        let newTripVC = NewTripViewController()
        newTripVC.delegate = self
        newTripVC.tripListVCRefresherDelegate = self
        let newTripNavCont = UINavigationController(rootViewController: newTripVC)
        newTripNavCont.navigationBar.prefersLargeTitles = false
        newTripNavCont.presentationController?.delegate = newTripVC
        present(newTripNavCont,animated: true)
        
    }
    
    func hideSortButton(){
        sortButton.isHidden = true
        sortButton.isEnabled = false
    }
    
    func showSortButton(){
        sortButton.isEnabled = true
        sortButton.isHidden = false
    }
    
    func hideSearchBar(){
        navigationItem.searchController = nil
        navigationController?.navigationBar.layoutIfNeeded()

    }
    
    func showSearchBar(){
        navigationItem.searchController = searchController
        navigationController?.navigationBar.layoutIfNeeded()
    }
}

extension TripListViewControllerOld:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if filterredData.count == 0{
            if indexName.count == 0{
                tableView.backgroundView = emptyTableView
                hideSearchBar()
                hideSortButton()
                return 0
            }
            showSearchBar()
            showSortButton()
            return indexName.count
        }else{
            
            hideSortButton()
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
            if tripDetailListData.count == 0{
                tableView.backgroundView = emptyTableView
                sortButton.isHidden = true
                sortButton.isEnabled = false
                return 0
            }
            else{
                sortButton.isHidden = false
                sortButton.isEnabled = true
                tableView.backgroundView = nil
            }
            
            let key = indexName[section]
            tableView.backgroundView = nil
            return indexedTripDetail[key]?.count ?? 0
        }
        else{
            tableView.backgroundView = nil
            return filterredData.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        tableView.bringSubviewToFront(containerView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let tripDetail = indexedTripDetail[indexName[indexPath.section]] else{
            return UITableViewCell()
        }
        var  tripDetailData = [TripDetails]()
        if !filterredData.isEmpty{
            tripDetailData = []
            tripDetailData.append(contentsOf: filterredData)
        }else{
            tripDetailData = []
            tripDetailData.append(contentsOf: tripDetail)
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TripListCell.identifier) as? TripListCell else{
            print("***Error while unwrapping cell @ triplist")
            return UITableViewCell()
        }
    
        cell.setMyShareLabel(with: tripDetailData[indexPath.row].myShare)
        cell.setTripNameLable(with: tripDetailData[indexPath.row].tripName)
        cell.setDateViewLable(with: tripDetailData[indexPath.row].startDate)
        cell.setFriendsCountLabel(with: tripDetailData[indexPath.row].friendsCount)
        cell.setTotalAmountLabel(with: tripDetailData[indexPath.row].totalExpense)
        
        return cell
    }
    
  
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        searchController.resignFirstResponder()
        
        var sectionwiseTrip = [TripDetails]()
        if filterredData.count == 0{
            let key = indexName[indexPath.section]
            sectionwiseTrip.append(contentsOf:  indexedTripDetail[key] ?? [])
        }
        else{
            sectionwiseTrip.append(contentsOf: filterredData)
        }
        
        let newVC = TripDetailedViewController(trip: sectionwiseTrip[indexPath.row])
        newVC.title = sectionwiseTrip[indexPath.row].tripName
        //newVC.tripList = self
//        newVC.selectedIndexPath = indexPath
        newVC.tripListVCRefresherDelegate = self

        show(newVC, sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if searchController.isActive && searchController.searchBar.text != ""{
            if filterredData.count == 0{
                return nil
            }
        }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier)as? HeaderView
        guard let header = header else{
            print("***Error while unwrapping header view")
            return UITableViewHeaderFooterView()
        }

        if filterredData.isEmpty{
            if indexName.count == 0{
                header.titleLabel.text = "0"
                return nil
            }
            header.titleLabel.text =  indexName[section]
            return header
        }
        else{
           return nil
        }
        
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let lastSection = indexName[indexName.count-1]
        if filterredData.count == 0  {
            if indexPath == IndexPath(row: (indexedTripDetail[lastSection]?.count ?? 0) - 1, section: indexName.count - 1) &&
            (totalEntries >= tripDetailListData.count) &&
            dataOffset <= totalEntries{
            dataOffset += dataLimit
            bringDataForUI()
        }
            
        }else{
            if indexPath.row == filterredData.count-1 && filterredData.count < totalSearchResultEntries && dataOffset <= totalEntries{
                dataOffset += dataLimit
                bringDataForUI()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var tripID = Int()
        var isHaveDues = false
        
        
        if self.filterredData.count != 0 {
            tripID = filterredData[indexPath.row].tripID

            if self.filterredData[indexPath.row].myShare != 0{
               isHaveDues = true
            }
        }else{
            let section = self.indexName[indexPath.section]
            tripID = indexedTripDetail[section]?[indexPath.row].tripID ?? 0
            if self.indexedTripDetail[section]?[indexPath.row].myShare != 0{
               isHaveDues = true
                
            }
        }
        
        
        let alert = UIAlertController(title: "⚠ Warning", message: "Are you sure want to remove trip detail permanently ?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style:.destructive , handler: {_ in
            self.deletionDelegate.deleteTrip(for: tripID)
            self.tripDetailListData.removeAll(where: {$0.tripID == tripID})

            if self.filterredData.count != 0{
                self.filterredData.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }else{
                let index = self.indexName[indexPath.section]
                self.indexedTripDetail[index]?.remove(at:  indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                if self.indexedTripDetail[index]?.isEmpty == true{
                    self.indexedTripDetail[index] = nil
                    self.indexName.removeAll(where: {$0 == index})
                    self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                    self.tableView.layoutIfNeeded()
                }
            }
            
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

extension TripListViewControllerOld:UISearchResultsUpdating,UISearchBarDelegate{
    func updateSearchResults(for searchController: UISearchController) {
        if !self.searchController.isActive{
            return
        }
        filterredData = []
        dataOffset = 0
        guard let text = searchController.searchBar.text?.lowercased() else{
            return
        }
        if text == "" {//&& text == previousSearchText{
            tableView.reloadData()
            return
        }
        (totalSearchResultEntries,filterredData) = SearchResultFromDBDelegate.searchInTirpListTabel(for: text, dataLimit: dataLimit, dataOffset: dataOffset)
        tableView.reloadData()
        previousSearchText = text
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
        filterredData = []
        dataOffset = 0
        bringDataForUI()
        if tripDetailListData.count > 0{
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: false)
        }
    }
    
}

extension TripListViewControllerOld:NewDetailInsertionVCDelegate{
    
    func insertIntoTableView() {
        dataOffset = 0
        bringDataForUI()
        
    }
}


extension TripListViewControllerOld:TripListVCRefresherDelegate{
    func refreshData() {
        bringDataForUI()
    }
}


extension TripListViewControllerOld:UISheetPresentationControllerDelegate{
    
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        view.alpha = 1
    }
    
    
}

extension TripListViewControllerOld:SortTripListDelegate,UpdateViewTransparencyDelegate{
    func updateAlpha() {
        view.alpha = 1

    }
    func updateSortKey(key: String) {
        
        dataOffset = 0
        sortKey = key
        userDefaults?.setValue(sortKey, forKey: userDefaults?.tripListSortKey ?? "")
        
        if tripDetailListData.count > 0{
            //tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at:.top, animated: true)
        tableView.layoutIfNeeded()
        }
        bringDataForUI()
    }
}

extension TripListViewControllerOld{
    func splitDataIntoSections(){
        switch sortKey{
        case SortViewController.dateDesc,SortViewController.dateAse : sortByDate()
        case SortViewController.nameAse,SortViewController.nameDesc:sortByName()
        case SortViewController.amountAsc,SortViewController.amountDesc : sortByAmount()
        default: sortByDate()
        }
        
    }
    
    func sortByDate(){
        let myDateformatter = DateFormatter()
        
        var groupedUsingDictionary = Dictionary(grouping: self.tripDetailListData) { (tripDetail) -> String  in
            myDateformatter.dateFormat = "MMM\ndd\nyyyy"
            guard let date = myDateformatter.date(from: tripDetail.startDate) else{
                return " "
            }
            myDateformatter.dateFormat = "MMM,yyyy"
            let monthWise = myDateformatter.string(from: date)
            return monthWise
        }
        let keys = groupedUsingDictionary.keys.sorted(by: {trip1,trip2 in
            
            guard let date1 = myDateformatter.date(from: trip1) else{
                return false
            }
            guard let date2 = myDateformatter.date(from: trip2) else{
                return false
            }
            if sortKey == SortViewController.dateDesc{
                return date2.timeIntervalSince1970 < date1.timeIntervalSince1970 }
            else{
                return date2.timeIntervalSince1970 > date1.timeIntervalSince1970
            }
        })
        
        myDateformatter.dateFormat = "MMM\ndd\nyyyy"
        for key in keys{
            groupedUsingDictionary[key]?.sort(by: { trip1,trip2 in
                guard let date1 = myDateformatter.date(from: trip1.startDate) else{
                    return false
                }
                guard let date2 = myDateformatter.date(from: trip2.startDate) else{
                    return false
                }
                if sortKey == SortViewController.dateDesc{
                    if date2.timeIntervalSince1970 == date1.timeIntervalSince1970{
                        return trip1.tripName < trip2.tripName
                    }else{
                        return  date2.timeIntervalSince1970 < date1.timeIntervalSince1970
                    }
                }else{
                    if date2.timeIntervalSince1970 == date1.timeIntervalSince1970{
                        return trip1.tripName < trip2.tripName
                    }else{
                        return  date2.timeIntervalSince1970 > date1.timeIntervalSince1970
                    }                }
            })
        }
        
        indexName = keys
        indexedTripDetail = groupedUsingDictionary
        
        
    }
    
    func sortByName(){
        var groupUsingDictionary = Dictionary(grouping: self.tripDetailListData) { (trip) -> String  in
            guard let first = trip.tripName.first?.uppercased() else{
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
                groupUsingDictionary[key]?.sort(by: {$0.tripName.lowercased() < $1.tripName.lowercased()})
            }else{
                groupUsingDictionary[key]?.sort(by: {$0.tripName.lowercased() > $1.tripName.lowercased()})
            }
        }
        indexName = keys
        indexedTripDetail = groupUsingDictionary
    }
    
    func sortByAmount(){
        var keys = [String]()
        var groupUsingKey = [String:[TripDetails]]()
        
        let needsToBePaid = "Needs To Be Paid"
        let toBeReceived = "To Be Received"
        let allSetteled = "All Setteled"
        
        for trip in tripDetailListData{
            
            switch trip.myShare{
            case let x where x < 0: groupUsingKey[needsToBePaid,default: []].append(trip)
            case let x where x > 0: groupUsingKey[toBeReceived,default: []].append(trip)
            case let x where x == 0 : groupUsingKey[allSetteled,default: []].append(trip)
            default: break
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
                    if trip1.myShare == trip2.myShare{
                        return trip1.tripName < trip2.tripName
                    }else{
                        return trip1.startDate < trip2.startDate
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
                groupUsingKey[key]?.sort(by: {trip1,trip2 in
                    if trip1.myShare == trip2.myShare{
                        return trip1.tripName > trip2.tripName
                    }else{
                        return trip1.startDate < trip2.startDate
                    }
                })
            }
        }
        
        indexedTripDetail = groupUsingKey
        indexName = keys
    }
}


extension TripListViewControllerOld{
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
}
