//
//  TripListPresenter.swift
//  Levy
//
//  Created by Praveenraj T on 26/05/22.
//

import Foundation
import UIKit

protocol ListViewDelegate:ListViewSectionCountDelegate,ListViewRecordCountInSectionDelegate,ListViewSelectionDelegate,ListViewSectionHeaderDelegate,ListViewRefresherDelegate{
    
}
protocol ListViewRefresherDelegate{
    func refresh()
}

protocol ListViewSectionCountDelegate{
    func getSectionCount()->Int
}
protocol ListViewRecordCountInSectionDelegate{
    func getRecordCount(for section:Int)->Int
}
protocol TableviewSwipeActionDelegate{
    func tableViewCellDidTailSwiped(at indexPath:IndexPath,onCompletion:@escaping (Int,Bool)->Void)
}


protocol ListViewSelectionDelegate{
    func getDetailViewFor(_ tripDetail:TripDetails)->TripDetailedViewController
}

protocol ListViewSectionHeaderDelegate{
    func heightForTableViewSectionHeader(for section:Int)->CGFloat
    func getSectionHeaderName(for section: Int) -> String?
}


protocol GetTripDataDelegate{
    func getTrip(for indexPath:IndexPath)->TripDetails?
}
protocol FetchNextTripBatchDelegate{
    func getNextSetOfTrip(isSearchActive:Bool)->Bool
}


protocol UpdateTripCellDelegate{
    func updateCellDetails(cell:TripListCell,with trip:TripDetails)
}



protocol FetchTripsDataDelegate{
    func fetchTripsData()
}

protocol UpdateSearchResultDelegate{
    func updateSearchResult(for searchController:UISearchController)
    func searchBarCancelButtonDidTapped()
    //func updateNextSetOfTrip(for searchText:String)
}
protocol TotalReturnSumDelegate{
    func getTotalReturn()->Double
    func getTotalOwingAmount()->Double
    func getTotalOwedAmount()->Double
}



protocol TripListPresenterDelegate:AnyObject,ListViewDelegate,UpdateSearchResultDelegate,TableviewSwipeActionDelegate,TotalReturnSumDelegate{
    var tripListVC:TripListVCDelegate? {get set}
    func viewLoaded()
    func fetchTripsData()
    func findIndexPath(for tripID:Int)->IndexPath?
    
    func getTrip(for indexPath:IndexPath)->TripDetails?
    func tableViewWillDisplayCell(_ tableView:UITableView,cell:UITableViewCell,at indexPath:IndexPath)
    func sortButtonDidTapped()
    func insertSymbolInTripVCDidTapped()
    func deleteTripDetail(with tripID:Int)->IndexPath?
    func shouldDeleteSection(at section:Int,onCompletion:(Bool)->Void)
}




class TripListPresenter{
    
    weak var tripListVC:TripListVCDelegate?
    
    let entriesCountDelegate:EntriesCountDelegate = UseCase()
    let tripListDelegate : TripListDelegate = UseCase()
    let SearchResultFromDBDelegate:SearchResultFromDBDelegate = UseCase()
    let totalReturnDelgate:TotalReturnDelegate = UseCase()
    let deletionDelegate : DeleteTripDelegate = UseCase()


    var indexedTripDetail = [String:[TripDetails]]()
    var indexName = [String]()
    var sortKey = SortViewController.dateDesc
    var totalEntries = Int(0)
    
    var groupedTrips:[String:[TripDetails]] = [:]
    
    var tripDetailListData = Set<TripDetails>()

    var filterredData = [TripDetails]()
    
    var dataOffset = Int(0)
    let defaultDataLimit = Int(7)
    var dataLimit = Int(7)
    var totalSearchResultEntries = Int(0)
    
    var searchText = String()
    
    
    init(){
        NotificationCenter.default.addObserver(self, selector: #selector(newTripDidAdded(notification:)), name: .newTripDidAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTripDetail(_:)), name: .updateTripDetail, object: nil)
    }
    
 
    
    @objc func updateTripDetail(_ notification:Notification){
        guard let updatedTrip = notification.userInfo?[UserInfoKeys.updateTrip] as? TripDetails else{
            return
        }
        //will update trip detail @ source & ui
        updateTripDetail( with: updatedTrip)
    }
    
    func updateTripDetail( with newTrip:TripDetails){
        if let oldTrip = tripDetailListData.first(where: {$0.tripID == newTrip.tripID}){
            tripDetailListData.remove(oldTrip)
        }
        tripDetailListData.insert(newTrip)
        guard let indexPath = findIndexPath(for: newTrip.tripID) else{return}
        if isSearchControllerActiveWithText(){
            filterredData[indexPath.row].updateDetail(with: newTrip)
        }else{
            let section = indexName[indexPath.section]
            indexedTripDetail[section]?[indexPath.row].updateDetail(with: newTrip)
        }
        DispatchQueue.main.async {
            if let cell = self.tripListVC?.tableView.cellForRow(at: indexPath) as? TripListCell{
                self.updateCellDetails(cell: cell, with: newTrip)
                self.tripListVC?.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    func findIndexPath(for tripID:Int)->IndexPath?{
        if filterredData.count != 0{
            if let index = filterredData.firstIndex(where: {$0.tripID == tripID}){
                return IndexPath(row: index, section: 0)
            }
            return nil
        }else{
            for key in indexName{
                if indexedTripDetail[key]?.contains(where: {$0.tripID == tripID}) == true{
                    guard let index = indexedTripDetail[key]?.firstIndex(where: {$0.tripID == tripID}) else{ return nil }
                    guard let section = indexName.firstIndex(of: key) else {return nil}
                    return IndexPath(row: index, section: section)
                }
            }
        }
        return nil
    }
    
    func updateCellDetails(cell:TripListCell,with trip:TripDetails){
        cell.setMyShareLabel(with: trip.myShare,totalExp: trip.totalExpense)
        cell.setDateViewLable(with: trip.startDate)
        cell.setTripNameLable(with: trip.tripName)
        cell.setTotalAmountLabel(with: trip.totalExpense)
        cell.setFriendsCountLabel(with: trip.friendsCount)
        cell.setDateViewLable(with: trip.startDate)
    }
    
    @objc func newTripDidAdded(notification:NSNotification){
            //1.find indexPath for newly added trip
        guard let trip = notification.userInfo?[UserInfoKeys.newTrip] as? TripDetails else{
            return
        }
            //2.if indexPath is visible then insert it into tableview
        
        tripDetailListData.insert(trip)
        splitDataIntoSections()
        tripListVC?.tableView.reloadData()
        
    }
    
    func fetchTripsData(){
        fetchAndUpdateSortKeyForTripList()
        tripDetailListData.insert(contentsOf:getTripListFromStorage(limit: dataLimit, offset: dataOffset, sortBy: sortKey))
        splitDataIntoSections()
    }
    
    func fetchAndUpdateSortKeyForTripList(){
        if let sortKeyValue = userDefaults?.value(forKey: userDefaults?.tripListSortKey ?? "") as? String{
        sortKey = sortKeyValue
        }
    }
    
    func updateTotalEntriesInTripList(){
        totalEntries = entriesCountDelegate.getEntriesCountInTripListTable()
    }
    
    func getTripListFromStorage(limit: Int , offset: Int, sortBy: String)->[TripDetails]{
        tripListDelegate.getEntireTripListFromDB(limit: limit, offset: offset, sortBy: sortBy)
    }
    
    func getTripListForSearch(for searchText:String,dataLimit: Int, dataOffset: Int)->(Int,[TripDetails]){
          SearchResultFromDBDelegate.searchInTirpListTabel(for: searchText, dataLimit: dataLimit, dataOffset: dataOffset)
    }
    
}

extension TripListPresenter:TripListPresenterDelegate{
    func refresh() {
        dataOffset = 0
        fetchTripsData()
    }
    func viewLoaded(){
        fetchTripsData()
    }
    
    func heightForTableViewSectionHeader(for section: Int)->CGFloat {
        if filterredData.isEmpty{
            if isSearchControllerActiveWithText(){
                return 0
            }
            return UITableView.automaticDimension
        }else{
            return 0
        }
    }
    
    func getDetailViewFor(_ tripDetail: TripDetails) -> TripDetailedViewController {
        let tripDetailVCPresenter = TripDetialVCPresenter(trip: tripDetail)
        let newVC = TripDetailedViewController(presenter: tripDetailVCPresenter)
        newVC.title = tripDetail.tripName
        return newVC
    }

    func tableViewWillDisplayCell(_ tableView:UITableView,cell:UITableViewCell,at indexPath: IndexPath) {
        
        let lastSection = tableView.numberOfSections - 1
        let lastRow = tableView.numberOfRows(inSection: lastSection) - 1
        if indexPath == IndexPath(row: lastRow, section: lastSection){
            if filterredData.isEmpty{
                if getNextSetOfTrip(isSearchActive: false){
                    tableView.reloadData()
                }
            }else{
                if getNextSetOfTrip(isSearchActive: true) {
                    tableView.reloadData()
                }
            }
        }
    }
    
    func searchBarCancelButtonDidTapped() {
        tripListVC?.searchController.isActive = false
        filterredData.removeAll()
        dataOffset = 0
        
        if filterredData.count > 0{
            tripListVC?.tableView.setContentOffset(CGPoint(x: 0, y:  -184), animated: true)
        }
        tripListVC?.tableView.reloadData()
    }
    
    func updateSearchResult(for searchController:UISearchController) {
        guard  let searchText = searchController.searchBar.text else {
            return
        }
        if searchText == "" {
            if self.searchText != ""{
                tripListVC?.tableView.reloadData()
            }
            self.searchText = searchText
            return
        }
        
        dataOffset = 0
        filterredData.removeAll()
        (totalSearchResultEntries,filterredData) = SearchResultFromDBDelegate.searchInTirpListTabel(for: searchText, dataLimit: dataLimit, dataOffset: dataOffset)
        self.searchText = searchText
        
        tripListVC?.tableView.reloadData()
        if filterredData.isEmpty{
            //show no result found screen
            showEmptySearchResultScreen()
        }else{
            tripListVC?.tableView.backgroundView = nil
        }
    }
    
    func showEmptySearchResultScreen(){
        if let tripListVC = tripListVC{
            Levy.emptySearchResult(for: tripListVC.tableView, in: tripListVC.view)
        }
    }
    
    func updateNextSetOfTrip(for searchText:String){
        var nextSetOfTrip = [TripDetails]()
        (totalSearchResultEntries,nextSetOfTrip) = SearchResultFromDBDelegate.searchInTirpListTabel(for: searchText, dataLimit: dataLimit, dataOffset: dataOffset)
        filterredData.append(contentsOf: nextSetOfTrip)
    }
    
    func getNextSetOfTrip(isSearchActive:Bool)->Bool {
        if !isSearchActive  {
            searchText = ""
            updateTotalEntriesInTripList()
            dataOffset += dataLimit
            if totalEntries > tripDetailListData.count {
                if dataOffset > totalEntries{
                    dataOffset = tripDetailListData.count - 1
                }
                fetchTripsData()
                return true
            }
        }
        else{
            dataOffset += dataLimit
            if  filterredData.count < totalSearchResultEntries {
                if dataOffset <= totalSearchResultEntries{
                    updateNextSetOfTrip(for:searchText)
                    return true
                }else{
                    dataOffset = filterredData.count - 1
                    updateNextSetOfTrip(for: searchText)
                    return true
                }
            }
        }
        return false
    }
    
    func isSearchControllerActiveWithText()->Bool{
        if tripListVC?.searchController.isActive == true && !(tripListVC?.searchController.searchBar.text?.isEmpty ?? true){
            return true
        }
        return false
    }
    
    func getSectionHeaderName(for section: Int) -> String? {
        if filterredData.isEmpty{
            if isSearchControllerActiveWithText(){
                return nil
            }
            return indexName[section]}
        else{
            return nil
        }
    }
    
    func getTrip(for indexPath: IndexPath)->TripDetails? {
        if filterredData.isEmpty{
            guard let trip = indexedTripDetail[indexName[indexPath.section]]?[indexPath.row] else{return nil}
            return trip
        }else{
            return filterredData[indexPath.row]
        }
    }
    
    func getSectionCount() -> Int {
        if filterredData.isEmpty{
            if indexName.count == 0{
                tripListVC?.tableView.backgroundView = tripListVC?.emptyTableView
                hideSearchBar()
                hideSortButton()
                return 0
            }
            tripListVC?.tableView.backgroundView = nil
            showSearchBar()
            showSortButton()
            return indexName.count
            
        }else{
            hideSortButton()
            return 1
        }
    }
    
    func getRecordCount(for section: Int)->Int {
        if filterredData.isEmpty{
            if isSearchControllerActiveWithText(){
                return 0
            }
            return indexedTripDetail[indexName[section]]?.count ?? 0
        }else{
            return filterredData.count
        }
    }
    
    func hideSortButton(){
        tripListVC?.sortButton.isHidden = true
        tripListVC?.sortButton.isEnabled = false
    }
    
    func showSortButton(){
        tripListVC?.sortButton.isEnabled = true
        tripListVC?.sortButton.isHidden = false
    }
    
    func hideSearchBar(){
        tripListVC?.navigationItem.searchController = nil
        tripListVC?.navigationController?.navigationBar.layoutIfNeeded()

    }
    
    func showSearchBar(){
        tripListVC?.navigationItem.searchController = tripListVC?.searchController
        tripListVC?.navigationController?.navigationBar.layoutIfNeeded()
    }
}


extension TripListPresenter{
    func splitDataIntoSections(){
        let (sortBy,order) = SortVCPresenter.splitSortKey(sortKey: sortKey)
            switch sortBy{
            case SortVCPresenter.dateRow : sortByDate(order: order)
            case SortVCPresenter.nameRow:sortByName(order:order)
            case SortVCPresenter.amountRow: sortByAmount(order: order)
            default: sortByDate(order:order)
            }
            
        }
    
    func sortByName(order:String){
        groupedTrips = groupTripsByName()
        let keys = getOrderredKeysForNameSorting()
        orderTirpsForNameSort(keys: keys,order: order)
        updateSortedTrips(keys: keys)
    }

    
    func updateSortedTrips(keys:[String]){
        indexName = keys
        indexedTripDetail = groupedTrips
        groupedTrips.removeAll()
    }
        
    func sortByDate(order:String){
        groupedTrips.removeAll()
        groupedTrips = groupTripsByDate()
        let keys = getOrderredKeysForDateSorting()
        orderTripsForDateSort(keys: keys,order:order)
        updateSortedTrips(keys: keys)
    }
    
    func sortByAmount(order:String){
        groupedTrips.removeAll()
        groupedTrips = groupTripByAmount()
        var keys = getOrderredKeysForAmountSort()
        keys = orderTripsForAmountSort(keys: keys,order:order)
        updateSortedTrips(keys: keys)
    }


    func groupTripsByDate()->[String:[TripDetails]]{
        let myDateformatter = DateFormatter()
        
        let groupedUsingDictionary = Dictionary(grouping: self.tripDetailListData) { (tripDetail) -> String  in
            myDateformatter.dateFormat = "MMM\ndd\nyyyy"
            guard let date = myDateformatter.date(from: tripDetail.startDate) else{
                return " "
            }
            myDateformatter.dateFormat = "MMM,yyyy"
            let monthWise = myDateformatter.string(from: date)
            return monthWise
        }
        
        return groupedUsingDictionary
    }
    
    func getOrderredKeysForDateSorting()->[String]{
        let myDateformatter = DateFormatter()
        myDateformatter.dateFormat = "MMM\ndd\nyyyy"
        let keys = groupedTrips.keys.sorted(by: {trip1,trip2 in
            guard let date1 = myDateformatter.date(from: trip1) else{return false}
            guard let date2 = myDateformatter.date(from: trip2) else{return false}
            if sortKey == SortViewController.dateDesc{
                return date2.timeIntervalSince1970 < date1.timeIntervalSince1970 }
            else{
                return date2.timeIntervalSince1970 > date1.timeIntervalSince1970 }
        })
        return keys
    }
    
    func orderTripsForDateSort(keys:[String],order:String){
        let myDateformatter = DateFormatter()
        myDateformatter.dateFormat = "MMM\ndd\nyyyy"
        for key in keys{
            self.groupedTrips[key]?.sort(by: { trip1,trip2 in
                guard let date1 = myDateformatter.date(from: trip1.startDate) else{return false}
                guard let date2 = myDateformatter.date(from: trip2.startDate) else{
                    return false
                }
                if SortVCPresenter.Descending == order{
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
                    }
                }
            })
        }
    }
    
    func groupTripsByName()->[String:[TripDetails]]{
        let groupedTrips = Dictionary(grouping: self.tripDetailListData) { (trip) -> String  in
           guard let first = trip.tripName.first?.uppercased() else{
               return " "
           }
           return String(first)
       }
        return groupedTrips
    }
    
    func getOrderredKeysForNameSorting()->[String]{
        var keys = [String]()
        if sortKey == SortViewController.nameAse{
            keys = groupedTrips.keys.sorted(by: { $0.uppercased() < $1.uppercased() })
        }else{
            keys = groupedTrips.keys.sorted(by: { $0.uppercased() > $1.uppercased() })
        }
        return keys
    }
    
    func orderTirpsForNameSort(keys:[String],order:String){
        
        for key in keys{
            if SortVCPresenter.Ascending == order{
                groupedTrips[key]?.sort(by: {trip1,trip2 in
                    if trip1.tripName.lowercased() == trip2.tripName.lowercased(){
                        return trip1.myShare > trip2.myShare
                    }else{
                    return trip1.tripName.lowercased() < trip2.tripName.lowercased()}})
            }else{
                groupedTrips[key]?.sort(by: {trip1,trip2 in
                    if trip1.tripName.lowercased() == trip2.tripName.lowercased(){
                        return trip1.myShare > trip2.myShare
                    }else{return trip1.tripName.lowercased() > trip2.tripName.lowercased()}})
            }
        }
    }
    
    func groupTripByAmount()-> [String:[TripDetails]]{
        let needsToBePaid = "Needs To Be Paid"
        let toBeReceived = "To Be Received"
        let allSetteled = "All Setteled"
        var groupedTripUsingDictionary = [String:[TripDetails]]()
        for trip in tripDetailListData{
            switch trip.myShare{
            case let x where x < 0: groupedTripUsingDictionary[needsToBePaid,default: []].append(trip)
            case let x where x > 0: groupedTripUsingDictionary[toBeReceived,default: []].append(trip)
            case let x where x == 0 : groupedTripUsingDictionary[allSetteled,default: []].append(trip)
            default: break
            }
        }
        return groupedTripUsingDictionary
    }
    
    func getOrderredKeysForAmountSort()->[String]{
        let needsToBePaid = "Needs To Be Paid"
        let toBeReceived = "To Be Received"
        let allSetteled = "All Setteled"
        var keys = [String]()
        if sortKey == SortViewController.amountAsc{
            keys = [needsToBePaid,toBeReceived,allSetteled]
        }else{
            keys = [toBeReceived,needsToBePaid,allSetteled]
        }
        return keys
    }
    
    func orderTripsForAmountSort(keys:[String],order:String)->[String]{
        var keys = keys
        if SortVCPresenter.Ascending == order{
            for key in keys{
                if groupedTrips[key]?.count == nil{
                    keys.removeAll(where: {$0 == key})
                    continue
                }
                groupedTrips[key]?.sort(by: {trip1,trip2 in
                    if trip1.myShare == trip2.myShare{
                        return trip1.tripName < trip2.tripName
                    }else{
                        return trip1.myShare < trip2.myShare
                    }
                })
            }
        }else{
            for key in keys{
                if groupedTrips[key]?.count == nil{
                    keys.removeAll(where: {$0 == key})
                    continue
                }
                groupedTrips[key]?.sort(by: {trip1,trip2 in
                    if trip1.myShare == trip2.myShare{
                        return trip1.tripName < trip2.tripName
                    }else{
                        return trip1.myShare > trip2.myShare
                    }
                })
            }
        }
        return keys
    }
}

//sorting operation
extension TripListPresenter:UpdateViewTransparencyDelegate,SortTripListDelegate{
    @objc func sortButtonDidTapped(){
        let sortVCPresenter = SortVCPresenter(selectedKey: sortKey)
        sortVCPresenter.sortTripListDelegate = self
        sortVCPresenter.updateViewTransparencyDelegate = self

        let sortvc =  SortViewController(presenter: sortVCPresenter)
        sortvc.title = "Sort "
        let navCont = UINavigationController(rootViewController: sortvc)
        navCont.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            navCont.sheetPresentationController?.detents = [.medium()]
        }
        tripListVC?.present(navCont, animated: true, completion: nil)
        tripListVC?.view.alpha = 0.2
    }
    
    func updateAlpha() {
        tripListVC?.view.alpha = 1
    }
    
    func updateSortKey(key: String) {
        dataOffset = 0
        sortKey = key
        userDefaults?.setValue(sortKey, forKey: userDefaults?.tripListSortKey ?? "")
        
        if tripDetailListData.count > 0{
            tripListVC?.tableView.setContentOffset(CGPoint(x: 0, y: -184), animated: true)
            tripListVC?.tableView.layoutIfNeeded()
        }
        tripDetailListData.removeAll()
        fetchTripsData()
        tripListVC?.tableView.reloadData()
    }
    
    func getTotalReturn()->Double{
        let sum = totalReturnDelgate.getTotalReturn()
        return sum
    }
    

    
    func getTotalOwingAmount()->Double{
        let sum = totalReturnDelgate.getTotalOwingAmount().magnitude
        return sum
    }
    
    func getTotalOwedAmount()->Double{
        let sum = totalReturnDelgate.getTotalOwedAmount()
        return sum
    }
}


extension TripListPresenter{

    
    func tableViewCellDidTailSwiped(at indexPath: IndexPath,onCompletion:@escaping (Int,Bool)->Void) {
        guard let tripID = getTripID(for: indexPath) else{return}
        if isTripHaveUnclearedDues(tripID: tripID){
            onCompletion(tripID,true)
            return
        }else{
            onCompletion(tripID,false)
        }
    }
    
    func deleteTripDetail(with tripID:Int)->IndexPath?{
        deletionDelegate.deleteTrip(for: tripID)
        guard let trip = tripDetailListData.first(where: {$0.tripID == tripID})else{
            return nil
        }
        tripDetailListData.remove(trip)
        guard let indexPath = findIndexPath(for: tripID) else{return nil}
        if filterredData.isEmpty{
            let section = indexName[indexPath.section]
            indexedTripDetail[section]?.remove(at: indexPath.row)
        }else{
            filterredData.remove(at: indexPath.row)
        }
        return indexPath
    }
    
    
    func shouldDeleteSection(at section:Int,onCompletion:(Bool)->Void){
        let index = indexName[section]
        if indexedTripDetail[index]?.isEmpty == true{
            indexedTripDetail[index] = nil
            indexName.removeAll(where: {$0 == index})
            onCompletion(true)
        }
        onCompletion(false)
    }

    
    func getTripID(for indexPath:IndexPath)->Int?{
        if filterredData.count == 0{
            let sectionName = indexName[indexPath.section]
            return indexedTripDetail[sectionName]?[indexPath.row].tripID
        }else{
            return filterredData[indexPath.row].tripID
        }
    }
    
    func isTripHaveUnclearedDues(tripID : Int)->Bool{
        guard let trip = tripDetailListData.first(where: {$0.tripID == tripID}) else{
            return true
        }
        if trip.myShare != 0{
            return true
        }else{
            return false
        }
    }
}

extension TripListPresenter{

    @objc func insertSymbolInTripVCDidTapped(){
        
        let newTripVC = NewTripViewController()
        //newTripVC.delegate = self
        //newTripVC.tripListVCRefresherDelegate = self
        let newTripNavCont = UINavigationController(rootViewController: newTripVC)
        newTripNavCont.navigationBar.prefersLargeTitles = false
        newTripNavCont.presentationController?.delegate = newTripVC
            tripListVC?.present(newTripNavCont,animated: true)
        
    }
        
     
}
