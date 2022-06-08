//
//  SortVCPresenter.swift
//  Levy
//
//  Created by Praveenraj T on 30/05/22.
//

import Foundation
import UIKit

protocol UpdatePreselectedSortTypeDelegate{
    func selectCurrentSortType()
}

class SortVCPresenter:NSObject{
    static let Ascending = "ASC"
    static let Descending = "DESC"
    
    static let dateRow = "Date"
    static let nameRow = "Name"
    static let amountRow = "Amount"
    static let keySplitter :Character = "_"

    weak var sortTripListDelegate:SortTripListDelegate?
    weak var updateViewTransparencyDelegate:UpdateViewTransparencyDelegate?
    
    var sortOptions = [SortViewController.dateRow,SortViewController.nameRow,SortViewController.amountRow]
    
    var preSelectedOrder = String()

    var selectedOrder = SortViewController.Ascending
    
    var selectedSortBy = SortViewController.nameRow
    
    weak var sortVC:SortViewController?
    
    init(selectedKey:String,options:[String] = []){
        preSelectedOrder = selectedKey
        (selectedSortBy,selectedOrder) = SortVCPresenter.splitSortKey(sortKey: preSelectedOrder)
        if !options.isEmpty{
        sortOptions = options
        }
    }
    
    
    
    @objc func segmentButtonDidTapped(_ button:UISegmentedControl){
        if button.selectedSegmentIndex == 0{
            selectedOrder = SortViewController.Ascending
        }else{
            selectedOrder = SortViewController.Descending
        }
        updateDoneBarButtonEnableState()
    }
    
    func updateDoneBarButtonEnableState(){
        if preSelectedOrder == SortVCPresenter.getSortKey(sortBy: selectedSortBy, sortOrder: selectedOrder){
            sortVC?.doneBarButton.isEnabled = false
        }else{
            sortVC?.doneBarButton.isEnabled = true
        }
    }

    
    @objc func doneButtonDidTapped(){
        let key = SortVCPresenter.getSortKey(sortBy: selectedSortBy, sortOrder: selectedOrder)
        updateViewTransparencyDelegate?.updateAlpha()
        sortTripListDelegate?.updateSortKey(key: key)

            sortVC?.dismiss(animated: true)
    }
    
    @objc func willCloseSortViewcontroller(){
        updateViewTransparencyDelegate?.updateAlpha()
            sortVC?.dismiss(animated: true)
    }
    
}
extension SortVCPresenter{
    static func getSortKey(sortBy:String,sortOrder:String)->String{
        //Name+ASC = Name_ASC
        var sort = sortBy
        sort.append(keySplitter)
        return sort+sortOrder
    }
    
    static func splitSortKey(sortKey:String)->(String,String){
        let splitted = sortKey.split(separator: keySplitter)
        return (String(splitted[0]),String(splitted[1]))
    }
}

extension SortVCPresenter:UpdatePreselectedSortTypeDelegate{
    func selectCurrentSortType(){
        let (sortBy,order) = SortVCPresenter.splitSortKey(sortKey: preSelectedOrder)
        selectSegmentButton(order: order)
        selectSortByElement(sortBy: sortBy)
    }
    
    func selectSegmentButton(order:String){
        switch order{
        case SortViewController.Ascending: sortVC?.sortTypeSegmentButton.selectedSegmentIndex = 0
        case SortViewController.Descending: sortVC?.sortTypeSegmentButton.selectedSegmentIndex = 1
        default: sortVC?.sortTypeSegmentButton.selectedSegmentIndex = 1
        }
    }
    
    func selectSortByElement(sortBy:String){
        guard let sortVC = sortVC else{return}
        if let index = sortOptions.firstIndex(where: {$0 == sortBy}){
            let indexPath = IndexPath(row: index, section: 0)
            sortVC.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            tableView(sortVC.tableView, didSelectRowAt: indexPath)
        } else{
            let indexPath = IndexPath(row: 0, section: 0)
            sortVC.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            tableView(sortVC.tableView, didSelectRowAt: indexPath)
        }
    }
}

extension SortVCPresenter:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DefaultCell.identifier) as? DefaultCell else{
            return UITableViewCell()
        }
        cell.titleLabel.text = sortOptions[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? DefaultCell else{
            return
        }
        cell.titleLabel.textColor = myThemeColor
        cell.accessoryView = sortVC?.customCheck
        
        if let sortBy = cell.titleLabel.text{
            selectedSortBy = sortBy
        }
        updateDoneBarButtonEnableState()
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let cell = tableView.cellForRow(at: indexPath) as? DefaultCell else{
            return nil
        }
        cell.titleLabel.textColor = .label
        cell.accessoryView = nil
        return indexPath
    }
}
