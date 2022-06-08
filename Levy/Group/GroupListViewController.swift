//
//  GroupListViewController.swift
//  Levy
//
//  Created by Praveenraj T on 29/03/22.
//

import UIKit
import Network

protocol UpdateGroupListDelegate:AnyObject{
    func updateGroupList()
}

class GroupListViewController: UITableViewController {
    
    static let cellIdentifier = "cell"
    
    let groupDBDelegate:GroupDBDelegate = UseCase()
    let groupWiseSumUpdationDelegate:GroupWiseSumUpdationDelegate = UseCase()
    let networkHeleperDelegate:NetworkHelperDelegate = UseCase()
    let deleteGroupDelegate:DeleteGroupDelegate = UseCase()


    private var isErrorShownToUser = false
    
    private let groupImageCache:NSCache<AnyObject,UIImage> = {
        let cache = NSCache<AnyObject,UIImage>()
        cache.countLimit = 30
        cache.totalCostLimit = 1024*1024*75
        return cache
    }()
    
    var groupListDetail = [GroupDetails]()
    
    private var filterredData = [GroupDetails]()
    
    private var searchController:UISearchController = {
        let searchCont = UISearchController()
        searchCont.searchBar.autocapitalizationType = .none
        searchCont.searchBar.placeholder = "Search Groups"

        return searchCont
        
    }()
    
    private lazy var emptyTableView:ViewForEmptyTableview = {
        let view = ViewForEmptyTableview()
        view.actionButton.setTitle("Form Group", for: .normal)
        view.primaryLabel.text = "No Group Formed"
        view.secondaryLabel.text = nil
        
        view.actionButton.addTarget(self, action: #selector(insertSymbolInGroupVCDidTapped), for: .touchUpInside)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        
        configureTableView()
        configureSearchController()
        bringDataForUI()
        
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertSymbolInGroupVCDidTapped))
    }
    
    override func bringDataForUI() {
        groupWiseSumUpdationDelegate.updateGroupWiseSum()
        groupListDetail = groupDBDelegate.getGroupDetailList()
        tableView.reloadData()
    }
    
    
    private func configureTableView(){
        tableView.backgroundColor = .secondarySystemBackground
        tableView.separatorStyle = .none
        tableView.register(GroupListTableViewCell.self, forCellReuseIdentifier: GroupListViewController.cellIdentifier)
        
    }
    
    
    private func configureSearchController(){
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    @objc private func insertSymbolInGroupVCDidTapped(){
        let newGroupVC = NewGroupInsertionViewController()
        newGroupVC.updateGroupListDelegate = self
        let newGroupNavCont = UINavigationController(rootViewController: newGroupVC)
        
        newGroupNavCont.navigationBar.prefersLargeTitles = false
        newGroupNavCont.view.backgroundColor = .systemBackground
        newGroupNavCont.presentationController?.delegate = newGroupVC
        present(newGroupNavCont,animated: true)
    }
    
}

extension GroupListViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groupListDetail.count == 0{
            tableView.backgroundView = emptyTableView
            return 0
        }
        else{
            tableView.backgroundView = nil
        }
        
        if filterredData.count == 0{
            if searchController.isActive && searchController.searchBar.text != ""{
                Levy.emptySearchResult(for: tableView, in: view)
                return 0
            }
            else{
                tableView.backgroundView = nil
            }
            return groupListDetail.count
        }else{
            tableView.backgroundView = nil
            return filterredData.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupListViewController.cellIdentifier) as! GroupListTableViewCell
        
        if filterredData.count == 0{
            cell.setGoupNameLabel(with: groupListDetail[indexPath.row].groupName)
            cell.setGroupDescriptionLabel(with: groupListDetail[indexPath.row].groupDescription)
            cell.setShareAmountLabel(with: groupListDetail[indexPath.row].amount)
            getAndSetImage(for: indexPath)
            
        }
        else{
            cell.setGoupNameLabel(with: filterredData[indexPath.row].groupName)
            cell.setGroupDescriptionLabel(with: filterredData[indexPath.row].groupDescription)
            cell.setShareAmountLabel(with: filterredData[indexPath.row].amount)
            getAndSetImage(for: indexPath)
            
        }
        return cell
    }
    
    
    private func getAndSetImage(for indexPath:IndexPath){
        var url = String()
        if filterredData.count == 0{
            url = groupListDetail[indexPath.row].groupImageURLString
        }else{
            url = filterredData[indexPath.row].groupImageURLString
        }
        
        if url == ""{
            var image = UIImage()
            if #available(iOS 14.0, *){
                image = UIImage(systemName: "photo.circle")!
            }
            else{
                image = UIImage(systemName: "photo")!
            }
            DispatchQueue.main.async {
            self.didGetImage(for: indexPath, image: image,isTemperoryImage: true)
            }
            return
        }
        
        networkHeleperDelegate.getImage(for: url, searchText: "",cache:groupImageCache as? NSCache<AnyObject, AnyObject> , onCompletion: {image,error,_,isFromCache  in
            if error != nil {
                DispatchQueue.main.async { [self] in
                    self.didGetImage(for: indexPath, image: UIImage(named:"groups"),isTemperoryImage: true)
                }
                if !self.isErrorShownToUser{
                    DispatchQueue.main.async { [self] in
                        self.isErrorShownToUser = true
                        throwWarningToUser(viewController: self , title: "Error", errorMessage: error!.errorDescription!)
                    }
                }
            }
            else{
                guard let isFromCache = isFromCache else{
                    return
                }
                self.didGetImage(for: indexPath, image: image)

                if !isFromCache{
                    self.isErrorShownToUser = false
                    }
            }
        })
    }
    
    private func didGetImage(for indexPath:IndexPath,image:UIImage?,isTemperoryImage:Bool = false){
        
        guard let cell = tableView.cellForRow(at: indexPath) as? GroupListTableViewCell else{
            print("cell not visible")
            return
        }
        guard let image = image else {
            cell.setGroupImage(with: UIImage(systemName: "person.2.square.stack.fill"))
            return
        }
        
        if !isTemperoryImage{
            groupImageCache.setObject(image, forKey: groupListDetail[indexPath.row].groupImageURLString as AnyObject)
        }
        cell.setGroupImage(with: image)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let detailVC = GroupDetailedViewController()
        detailVC.groupListVCRefersherDelegate = self
        detailVC.addExpenseButton.setImage(UIImage(systemName: "paperplane"), for: .normal)
        
        if filterredData.count == 0{
            detailVC.selectedGroup = groupListDetail[indexPath.row]
            
        }else{
            detailVC.selectedGroup = filterredData[indexPath.row]
            
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var groupID = Int()
        var isHaveDues = false
        
        
        if self.filterredData.count != 0 {
            groupID = filterredData[indexPath.row].groupID

            if self.filterredData[indexPath.row].amount != 0{
               isHaveDues = true
                
            }
        }else{
            groupID = groupListDetail[indexPath.row].groupID
            if groupListDetail[indexPath.row].amount != 0{
                isHaveDues = true
            }
        }
        let alert = UIAlertController(title: "⚠ Warning", message: "Are you sure want to remove the group detail permanently ?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style:.destructive , handler: {_ in
                self.deleteGroupDelegate.deleteGroup(for:groupID)
            if self.filterredData.isEmpty{
                self.groupListDetail.remove(at: indexPath.row)
            }else{
                self.filterredData.remove(at: indexPath.row)
            }
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
            throwWarningToUser(viewController: self, title: "Group have uncleared dues", errorMessage: "Please clear all dues before deleting group detail.")
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

extension GroupListViewController:UpdateGroupListDelegate{
    func updateGroupList() {
        bringDataForUI()
    }
}

extension GroupListViewController:GroupListVCRefersherDelegate{
    func refresh() {
        bringDataForUI()
    }
}

extension GroupListViewController:UISearchResultsUpdating{
    
    internal func updateSearchResults(for searchController: UISearchController) {
        filterredData = []
        guard let text = searchController.searchBar.text?.lowercased() else{
            return
        }
        groupListDetail.forEach({
            cell in
            if cell.groupName.lowercased().contains(text) ||
                cell.groupDescription.lowercased().contains(text)  ||
                cell.amount.description.lowercased().contains(text) {
                self.filterredData.append(cell)
            }
        })
        
        if filterredData.count != 0{
            tableView.backgroundView = nil
        }
        tableView.reloadData()
    }
    
}


