//
//  FriendWiseExpDetailedVC.swift
//  Levy
//
//  Created by Praveenraj T on 22/03/22.
//

import UIKit

protocol RefresherForFriendWiseExpenseDelegate:AnyObject{
    func refreshData()
}

class FriendWiseExpDetailedVC: UIViewController {
    
    let selectedFriendWiseExpDelegate:SelectedFriendWiseExpDelegate = UseCase()
    let friendWiseExpDBDelegate :FriendWiseExpDBDelegate = UseCase()
    let settleUpFromFriendWiseDetailedDelegate :SettleUpFromFriendWiseDetailedDelegate = UseCase()
    weak var refresherForFriendWiseExpenseDelegate:RefresherForFriendWiseExpenseDelegate?
    
    var selectedFriend:FriendWiseExpense
    var amountNeedsToBePaid = Double(0)
    weak var actionToEnable : UIAlertAction?

    lazy var friendDetailTableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var detailsView:UIView = {
        let containerView = UIView()
        containerView.layer.shadowColor = UIColor(named: "shadow")?.cgColor
        
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.shadowOpacity = 0.5
        
        containerView.backgroundColor = .systemBackground
        containerView.alpha = 1
        
        containerView.layer.masksToBounds = false
        
        return containerView
    }()
    
    lazy var  myShareLabel :UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.alpha = 1
        label.layer.masksToBounds = true
        return label
    }()
    
    lazy var callButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        button.addTarget(self, action: #selector(callButtonDidTapped(_ :)), for: .touchUpInside)
        return button
    }()
    
    lazy var messageButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "message.fill"), for: .normal)
        button.addTarget(self, action: #selector(callButtonDidTapped(_ :)), for: .touchUpInside)
        return button
    }()
    
    lazy var faceTimeButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "video.fill"), for: .normal)
        button.addTarget(self, action: #selector(callButtonDidTapped(_ :)), for: .touchUpInside)
        return button
    }()
    
    lazy var stackView:UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(callButton)
        stackView.addArrangedSubview(messageButton)
        stackView.addArrangedSubview(faceTimeButton)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        stackView.clipsToBounds = true
        stackView.layer.cornerRadius = 5
        
        stackView.backgroundColor = .secondarySystemFill
        stackView.layer.shadowColor = UIColor.black.cgColor
        stackView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        return stackView
    }()
    
    
    let formatter :NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()
    
    var tripListData = [TripDetails]()
    
    init(friend:FriendWiseExpense){
        selectedFriend = friend
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureDetailView()
        configureTripDetailTableView()
        
        bringDataForUI()
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func configureDetailView(){
        view.addSubview(detailsView)
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        detailsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        detailsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        detailsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        detailsView.heightAnchor.constraint(equalToConstant: 115).isActive = true
        
        detailsView.addSubview(myShareLabel)
        myShareLabel.translatesAutoresizingMaskIntoConstraints = false
        myShareLabel.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: 5).isActive = true
        myShareLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 5).isActive = true
        myShareLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -5).isActive = true
        myShareLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        detailsView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: myShareLabel.bottomAnchor, constant: 5).isActive = true
        stackView.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 5).isActive = true
        stackView.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -5).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    override func bringDataForUI() {
        guard let updatedFriendDetail = selectedFriendWiseExpDelegate.getFriendwiseExp(friendID: selectedFriend.friendID) else{
            print("***Error:while unwrapping updated friend")
            return
        }
        selectedFriend = updatedFriendDetail
        tripListData = friendWiseExpDBDelegate.getTripListFromDB(for: selectedFriend.friendID)
        
        guard let currency = Locale.current.currencySymbol else{
            print("***Error while unwrapping currency")
            return
        }
        if selectedFriend.totalReturn >= 0{
            let attrString = NSMutableAttributedString(string:currency+" "+selectedFriend.totalReturn.description+"\n", attributes: [.font:UIFont.boldSystemFont(ofSize: 20),.foregroundColor:UIColor.systemGreen])
            let suffix = NSMutableAttributedString(string: "to be received", attributes: [.font:UIFont.systemFont(ofSize: 13),.foregroundColor:UIColor.systemGreen])
            attrString.append(suffix)
            myShareLabel.attributedText = attrString
        }else{
            let attrString = NSMutableAttributedString(string:currency+" "+selectedFriend.totalReturn.magnitude.description+"\n", attributes: [.font:UIFont.boldSystemFont(ofSize: 20),.foregroundColor:UIColor.systemRed])
            let suffix = NSMutableAttributedString(string: "needs to be paid", attributes: [.font:UIFont.systemFont(ofSize: 13),.foregroundColor:UIColor.systemRed])
            attrString.append(suffix)
            myShareLabel.attributedText = attrString
        }
        friendDetailTableView.reloadData()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refresherForFriendWiseExpenseDelegate?.refreshData()
    }
    
    func configureTripDetailTableView(){
        view.addSubview(friendDetailTableView)
        
        friendDetailTableView.delegate = self
        friendDetailTableView.dataSource = self
        
        friendDetailTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            friendDetailTableView.topAnchor.constraint(equalTo: detailsView.bottomAnchor, constant: 10),
            friendDetailTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            friendDetailTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            friendDetailTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
        ])
        
        
        friendDetailTableView.register(ExpesenceDetailCell.self, forCellReuseIdentifier: "Expense")
        friendDetailTableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
    }
    
    @objc func callButtonDidTapped(_ button:UIButton){
        var appName = String()
        if button == callButton{
            appName = "tel"
        }else if button == messageButton{
            appName = "sms"
        }else if button == faceTimeButton{
            appName = "facetime"
        }
        
        let phoneNo = (appName+"://\(selectedFriend.phoneNumber)").replacingOccurrences(of: " ", with: "")
        
        guard let url = URL(string: phoneNo) else {
            print("url error")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url,options: [:])
        }
        else{
            print("call error")
        }
    }
}

extension FriendWiseExpDetailedVC:UITableViewDelegate,UITableViewDataSource{

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? HeaderView
        guard let header = header else{
            print("***Error while unwrapping header")
            return UITableViewHeaderFooterView()
        }
        
        header.titleLabel.text = "Trips"
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tripListData.count == 0{
            let view = ViewForEmptyTableview()
            view.primaryLabel.text = "Not linked with any trips"
            view.actionButton.isHidden = true
            view.actionButton.isEnabled = false
            tableView.backgroundView = view
            return 0
        }
        tableView.backgroundView = nil
        return tripListData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Expense") as? ExpesenceDetailCell
        
        guard let cell = cell else{
            print("cell creation error - tripdetailed vc")
            return UITableViewCell()
        }
        
        if !tripListData.isEmpty{
            cell.setTitlelabel(with: tripListData[indexPath.row].tripName)
            cell.bottomLeftButton.isHidden = true
            cell.bottomLeftButton.isEnabled = false
            cell.bottomLeftButtonHeightAnchor.isActive = false
            cell.bottomLeftButtonZeroHeight.isActive = true

            cell.setTopRightLable(with: tripListData[indexPath.row].myShare)
            if tripListData[indexPath.row].myShare == 0{
                cell.updateUIForAllSettledState()

            }
            else{
                cell.updateUIForSettleState()
            }
           
            cell.settleupButtonDelegate = self
            cell.selectionStyle = .none
        }
        return cell
    }
        
}


extension FriendWiseExpDetailedVC:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxCharacterInTextField = 8
        
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


extension FriendWiseExpDetailedVC:SettleupButtonDelegate{
    @objc func textChanged(_ sender:UITextField) {
        self.actionToEnable?.isEnabled  = (sender.text! != "")
    }
    
    func settleupButtonDidTappd(at cell: UITableViewCell) {
        guard let index = friendDetailTableView.indexPath(for: cell) else{
            print("Error-cell not found")
            return
        }
        
        amountNeedsToBePaid = tripListData[index.row].myShare.magnitude
        
        let alert = UIAlertController(title: "", message: "Enter Settle-Up Amount", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {newText in
            newText.placeholder = "Enter Settle Up Amount"
            newText.keyboardType = .decimalPad
            newText.delegate = self
            newText.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "OK", style: .default,handler: { [self]_ in
            alert.textFields?.first?.resignFirstResponder()
            guard let amountText =  alert.textFields?.first?.text else{
                return
            }
            let formatter = NumberFormatter()
            formatter.decimalSeparator = Locale.current.decimalSeparator
            
            guard let paidAmount = formatter.number(from: amountText) as? Double else{
                return}
            
            if tripListData[index.row].myShare > 0{
                settleUpFromFriendWiseDetailedDelegate.settledUp(friendID: selectedFriend.friendID, tripID: tripListData[index.row].tripID, amount: paidAmount)
            }
            else {
                settleUpFromFriendWiseDetailedDelegate.settledUp(friendID: selectedFriend.friendID, tripID: tripListData[index.row].tripID, amount: -paidAmount)
            }
            isExpenseUpdated = true
            bringDataForUI()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.actionToEnable = okAction
        okAction.isEnabled = false
        alert.preferredAction = okAction

        present(alert,animated: true)

    }
}
