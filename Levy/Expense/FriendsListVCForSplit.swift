//
//  FriendsListVCForSplit.swift
//  Levy
//
//  Created by Praveenraj T on 16/03/22.
//

import UIKit

protocol SelectedFriendsForExpenseDelegate:AnyObject{
    func updateSelectedFriends(id:[String],isMultiselected:Bool)
}




class FriendsListVCForSplit :UIViewController{

    let delegate : TripDetailDBDelegate = UseCase()
    weak var selectedFriendsDelegate:SelectedFriendsForExpenseDelegate?
    
    var friendsInTrip :[FriendsInTrip]
    let myName = "Me "
    let myID = "0"
    
    var isMultiSelectionEnabled = false
    
    var totalRowSelected: [String] {
        willSet{
            if selectFriendsIDold.containsSameElements(as: newValue){
                doneBarButton.isEnabled = false
            }
            else{
                doneBarButton.isEnabled = true
            }

        }
    }
    
    let tableView :UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.rowHeight = 60
        return table
    }()

    
    var selectFriendsIDold = [String]()
        
    let expenseAmount = Double.zero
    
    lazy var doneBarButton:UIBarButtonItem = {
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonDidTapped))
       done.isEnabled  = false
       return done
   }()
    
    init(needMultiselection:Bool,selectedTrip:Int,selectedID:[String]){
        friendsInTrip = delegate.getEntireFrindsInTripFromDB(for: selectedTrip)
        friendsInTrip.insert(FriendsInTrip(tripID: selectedTrip, friendID: myID, friendName: myName, friendPhoneNumber: " "), at: 0)
        
        totalRowSelected = []
        selectFriendsIDold = selectedID
        super.init(nibName: nil, bundle: nil)
        title = "Paid by"
        isMultiSelectionEnabled = needMultiselection
        tableView.allowsMultipleSelection = needMultiselection
        if needMultiselection{
            title = "Share With Friends"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.backgroundColor = .secondarySystemBackground

        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidTapped))
        navigationItem.largeTitleDisplayMode = .never
        
        self.isModalInPresentation = true
        configureTableView()
    }
    
   
    
    func configureTableView(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        tableView.register(FriendsListTableViewCell.self, forCellReuseIdentifier: "friends")

    }
    
    @objc func doneButtonDidTapped(){
        selectedFriendsDelegate?.updateSelectedFriends(id: totalRowSelected, isMultiselected: isMultiSelectionEnabled)
        dismiss(animated: true)
    }
    
    @objc func cancelButtonDidTapped(){
        if doneBarButton.isEnabled{
            let alerSheet = UIAlertController(title: nil, message: "Do you want to save changes?", preferredStyle: .actionSheet)
            alerSheet.addAction(UIAlertAction(title: "Save Changes", style: .cancel, handler: {_ in self.doneButtonDidTapped()}))
            alerSheet.addAction(UIAlertAction(title: "Discard Changes", style: .destructive, handler: {_ in
                self.dismiss(animated: true, completion: nil)
            }))
            alerSheet.popoverPresentationController?.sourceView = self.view
            let xOrigin = 0
            let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
            alerSheet.popoverPresentationController?.sourceRect = popoverRect
            alerSheet.popoverPresentationController?.permittedArrowDirections = .up
            present(alerSheet,animated: true)
        }else{
            dismiss(animated: true)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for friend in selectFriendsIDold{

            guard let index = friendsInTrip.firstIndex(where: {$0.friendID == friend}) else{
                return
            }
            let indexPath = IndexPath(row: index, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            tableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
}
extension FriendsListVCForSplit:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsInTrip.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableView.automaticDimension>120 ? UITableView.automaticDimension : 120
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friends") as? FriendsListTableViewCell
        guard let cell = cell else{
            print("*** Error: while unwrapping cell @ friendslistVCForSplit")
            return UITableViewCell()
        }
        cell.setFriendNameLabel(with: friendsInTrip[indexPath.row].friendName)
        cell.setPhoneNumberLabel(with: friendsInTrip[indexPath.row].friendPhoneNumber,textColor: .label)
        
        cell.selectionStyle = .none
        if totalRowSelected.contains(friendsInTrip[indexPath.row].friendID){
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("selected index ",indexPath)
        let cell = tableView.cellForRow(at: indexPath)
        
        let newSelection =  friendsInTrip[indexPath.row].friendID
        if isMultiSelectionEnabled{
            if totalRowSelected.contains(newSelection){
                return
            }
            totalRowSelected.append(newSelection)
                cell?.accessoryType = .checkmark
        
        }
        else{
            
            cell?.accessoryType = .checkmark
            totalRowSelected = []
            totalRowSelected.append(newSelection)
        }
       
    }
    
     func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
         let cell = tableView.cellForRow(at: indexPath)
         cell?.accessoryType = .none
         print("deslect ",indexPath)

         let deselected =  friendsInTrip[indexPath.row].friendID
         totalRowSelected.removeAll(where: {$0 == deselected})
         if totalRowSelected.count == 0 && isMultiSelectionEnabled{
             self.tableView(tableView, didSelectRowAt: indexPath)
         }
          
     }
    
    

}




extension FriendsListVCForSplit:UIAdaptivePresentationControllerDelegate{
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        cancelButtonDidTapped()
    }
}
