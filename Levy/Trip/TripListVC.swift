//
//  TripListVC.swift
//  Levy
//
//  Created by Praveenraj T on 26/05/22.
//

import Foundation
//
//  TripListViewController.swift
//  Levy
//
//  Created by Praveenraj T on 08/03/22.
//

import UIKit

protocol TripListVCDelegate:UIViewController{
    var tableView:UITableView {get }
    var emptyTableView:ViewForEmptyTableview {get set}
    var searchController:UISearchController {get set}
    var sortButton:UIButton {get set}
    var totalLabel:UILabel {get set}
    var totalOwedLabel:UILabel {get set}
    var totalOwingLabel:UILabel {get set}
}

class TripListViewController: UIViewController,TripListVCDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate {
    
    var presenter : TripListPresenterDelegate

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
    
    var totalLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.setContentCompressionResistancePriority(UILayoutPriority(255), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(255), for: .horizontal)
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

    let balanceAnatomyView:UIView={
        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width:0, height: 60)))
//        view.backgroundColor = .systemBackground
//        view.clipsToBounds = true
//        view.layer.cornerRadius = 10
        return view
    }()
    
    var totalOwedLabel:UILabel = {
        let label = UILabel()
        label.textColor = .systemGreen
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "You owed \n1000"
        label.backgroundColor = .systemBackground
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        //label.setContentHuggingPriority(UILayoutPriority(255), for: .horizontal)
        return label
    }()
    
    var totalOwingLabel:UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "You owe \n1000"
        label.backgroundColor = .systemBackground
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        return label
    }()
    
    lazy var stackViewForAddButton:UIStackView = {
        let stackview = UIStackView()
        stackview.distribution = .fill
        stackview.axis = .horizontal
        stackview.alignment = .center
        stackview.spacing = 50
        
        return stackview
    }()
    
    lazy var refreshControl:UIRefreshControl = {
        let refersher = UIRefreshControl()
        refersher.attributedTitle = NSAttributedString(string: "Refresh")
        refersher.addTarget(self, action: #selector(refershData), for: .valueChanged)
        return refersher
    }()
        
    @objc func refershData(){
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
        print("\n\n****")
        presenter.refresh()

    }
    
    init(presenter:TripListPresenter){
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.presenter.tripListVC = self

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        print("trip list vc will deinitialized")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Trips"

        configureTableView()
        configureConteinerView()
        configureSortButton()
        configureTotalLabel()
        configureSearchController()
        configureBalanceAnatomyView()
        configureOwingLabel()
        configureOwedLabel()
        
        updateTotalLabelValue()
        updateAnatomyLablesValue()

        presenter.viewLoaded()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertSymbolInTripVCDidTapped))
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteTrip(_:)), name: .tripDidDeleted, object: nil)
    }
            
    func configureBalanceAnatomyView(){
        balanceAnatomyView.frame.size.height = 60
        tableView.tableHeaderView = balanceAnatomyView
    }
    
    func configureOwingLabel(){
        balanceAnatomyView.addSubview(totalOwingLabel)
        totalOwingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        totalOwingLabel.topAnchor.constraint(equalTo: balanceAnatomyView.topAnchor,constant: 3).isActive = true
        totalOwingLabel.leadingAnchor.constraint(equalTo: balanceAnatomyView.leadingAnchor,constant: 3).isActive = true
        totalOwingLabel.trailingAnchor.constraint(equalTo: balanceAnatomyView.centerXAnchor,constant: -5).isActive = true
        totalOwingLabel.bottomAnchor.constraint(equalTo: balanceAnatomyView.bottomAnchor,constant: -3).isActive = true
    }
    
    func configureOwedLabel(){
        balanceAnatomyView.addSubview(totalOwedLabel)
        totalOwedLabel.translatesAutoresizingMaskIntoConstraints = false
        
        totalOwedLabel.topAnchor.constraint(equalTo: balanceAnatomyView.topAnchor,constant: 3).isActive = true
        totalOwedLabel.leadingAnchor.constraint(equalTo: balanceAnatomyView.centerXAnchor,constant: 5).isActive = true
        totalOwedLabel.trailingAnchor.constraint(equalTo: balanceAnatomyView.trailingAnchor,constant: -3).isActive = true
        totalOwedLabel.bottomAnchor.constraint(equalTo: totalOwingLabel.bottomAnchor).isActive = true
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
        tableView.refreshControl = refreshControl
        tableView.register(TripListCell.self, forCellReuseIdentifier: TripListCell.identifier)
        tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderView.identifier)
    }
    
    func updateAnatomyLablesValue(){
        updateOwingLabel()
        updateOwedLabel()
    }
    
    func updateOwingLabel(){
        let sum = presenter.getTotalOwingAmount()
        totalOwingLabel.text = "You're Owing\n "+(currencyFormatter().string(from: sum as NSNumber) ?? " ")
    }
    
    func updateOwedLabel(){
        let sum = presenter.getTotalOwedAmount()
        totalOwedLabel.text = "You Owed\n "+(currencyFormatter().string(from: sum as NSNumber) ?? " ")
    }
    
    func updateTotalLabelValue(){
        let sum = presenter.getTotalReturn()
        if sum >= 0{
            totalLabel.text = "Amount To Be Received "+(currencyFormatter().string(from: sum as NSNumber) ?? " ")
            totalLabel.textColor = .systemGreen
        }else{
            totalLabel.text = "Amount To Be Paid "+(currencyFormatter().string(from: sum.magnitude as NSNumber) ?? " ")
            totalLabel.textColor = .systemRed
        }
    }
    
    func isSearchActiveWithText()->Bool{
        if searchController.isActive == true && !(searchController.searchBar.text?.isEmpty ?? true){
            return true
        }
        return false
    }
    
    @objc func sortButtonDidTapped(){
        presenter.sortButtonDidTapped()
    }
    
    @objc func insertSymbolInTripVCDidTapped(){
        presenter.insertSymbolInTripVCDidTapped()
    }

    @objc func deleteTrip(_ notification:Notification){
        guard let tripID = notification.userInfo?[UserInfoKeys.tripID] as? Int else{
            return
        }
        deleteTripDetail(with: tripID)
    }


}

extension TripListViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        let sectionCount = presenter.getSectionCount()
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = presenter.getRecordCount(for: section)
        return rows
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        tableView.bringSubviewToFront(containerView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: TripListCell.identifier) as? TripListCell else{
            print("***Error while unwrapping cell @ triplist")
            return UITableViewCell()
        }

        guard let tripDetailData = presenter.getTrip(for: indexPath) else{
            return cell
        }
        cell.setDateViewLable(with: tripDetailData.startDate)
        cell.setTripNameLable(with: tripDetailData.tripName)
        cell.setMyShareLabel(with: tripDetailData.myShare, totalExp: tripDetailData.totalExpense)
        cell.setTotalAmountLabel(with: tripDetailData.totalExpense)
        cell.setFriendsCountLabel(with: tripDetailData.friendsCount)
        cell.setShadowPathForContainer()
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let trip = presenter.getTrip(for: indexPath) else { throwWarningToUser(viewController: self, title: "Something went wrong", errorMessage: "Something went wrong please contact admin.\nError_tripDetailedVc")
            return  }
        let detailedVC = presenter.getDetailViewFor(trip)
        show(detailedVC, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionTitle = presenter.getSectionHeaderName(for: section) else{
            return nil
        }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier) as? HeaderView
        guard let header = header else{
            print("***Error while unwrapping header view")
            return UITableViewHeaderFooterView()
        }
        header.setTitleLabel(with: sectionTitle)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        let height = presenter.heightForTableViewSectionHeader(for: section)
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.tableViewWillDisplayCell(tableView,cell:cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") {_,_,completion in
            self.presenter.tableViewCellDidTailSwiped(at: indexPath, onCompletion: {tripID,isTripHaveDues in
                if isTripHaveDues{
                    throwWarningToUser(viewController: self, title: "Trip have uncleared dues", errorMessage: "Please clear all dues before deleting trip detail.")
                }else{
                    self.shouldDeleteTripDetail(at: indexPath, onCompletion: {isConfirmedToDelete in
                        if isConfirmedToDelete{
                            self.deleteTripDetail(with: tripID)
                            NotificationCenter.default.post(name: .tripDidDeleted, object: nil,userInfo: [UserInfoKeys.tripID:tripID, UserInfoKeys.indexPath:indexPath])
                        }
                    })
                }
            })
            completion(true)
        }
        action.image = UIImage(systemName: "trash")
        let swipe =  UISwipeActionsConfiguration(actions: [action])
        return swipe
    }
    
}
extension TripListViewController{
    func deleteTripDetail(with tripID: Int){
        guard let indexPath = self.presenter.deleteTripDetail(with: tripID) else{
            return
        }
        
        DispatchQueue.main.async{
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.presenter.shouldDeleteSection(at: indexPath.section, onCompletion: {canDelete in
                if canDelete{
                    self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                }
            })
            self.tableView.layoutIfNeeded()
        }
    }
    
    func shouldDeleteTripDetail(at indexPath:IndexPath, onCompletion:@escaping (Bool)->Void){
        let alert = UIAlertController(title: "Warning", message: "Are you sure want to remove trip detail permanently ?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style:.destructive , handler:{_ in onCompletion(true)})
        let keepAction = UIAlertAction(title: "Keep", style: .cancel, handler:{_ in onCompletion(false)})
        
        alert.addAction(deleteAction)
        alert.addAction(keepAction)
        alert.preferredAction = keepAction
        if let cell = tableView.cellForRow(at: indexPath) as? TripListCell{
            alert.popoverPresentationController?.sourceView = cell
        }else{
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
        alert.popoverPresentationController?.permittedArrowDirections = .any
        present(alert, animated: true)
    }
}

//search
extension TripListViewController:UISearchResultsUpdating,UISearchBarDelegate{
    func updateSearchResults(for searchController: UISearchController) {
        presenter.updateSearchResult(for: searchController)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchBarCancelButtonDidTapped()
    }
}

