//
//  InsertExpense_ViewController.swift
//  Levy
//
//  Created by Praveenraj T on 15/03/22.
//

import UIKit

protocol NewExpenseDetailDelegate:AnyObject{
    func insertIntoExpenseListTableView()
}

class InsertExpenseViewController: NewDetailInsertionVC {
    static let ExpenseAmountCharecterLimit = 8

    let paidByButtonPrefix = "Paid-By : "
    let shareWithFrienButtonPrefix = "Share With Friends : "
    let myID = "0"
    let myName = "Me "
    
    weak var insertExpenseDelegate:NewExpenseDetailDelegate?
    weak var tripDetailVCRefresherDelegate:TripDetailVCRefresherDelegate?
    
    var expenseAmount = Double()
    var selectedTripID :Int
    
    let tripDetailDelegate : TripDetailDBDelegate = UseCase()
    let friendNameDelegate : FriendNameFromDBDelegate = UseCase()
    let expenseTableDelegate:ExpenseTableDelegate = UseCase()
    let splitShareTableDBDelegate:SplitShareTableDBDelegate = UseCase()
    let groupWiseSumUpdationDelegate:GroupWiseSumUpdationDelegate = UseCase()
    

    
    lazy var paidBy = [myID]
    lazy var shareWithFriendsID = tripDetailDelegate.getEntireFrindsInTripFromDB(for: selectedTripID).map({$0.friendID})
    
    lazy var entireFriendsID:[String] = {
        var friends = [myID]
        friends.append(contentsOf: shareWithFriendsID)
        return friends
    }()
    
    lazy var expenseNameLabel:UILabel = {
       let label = UILabel()
        guard let currency = Locale.current.currencySymbol else{
            return label
        }
       
        label.attributedText = createMandatoryText(for: "Expense (\(currency))")
       return label
   }()
    
    lazy var expenseTextField:UITextField = {
        let textField = UITextField()
        textField.placeholder = " Enter Expense Amount"
        
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textField.clearButtonMode = .whileEditing

        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        textField.leftViewMode = .always

        return textField
   }()
    
    lazy var paidByButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(paidByButtonPrefix+myName, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.titleLabel?.textAlignment = .left
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.backgroundColor = UIColor(named: "myTheme")
        button.setTitleColor(.systemBackground, for: .normal)
        
        if #available(iOS 15.0, *){
            var config = UIButton.Configuration.borderless()
            config.imagePlacement = .trailing
            config.imagePadding = 10
            button.configuration = config
        }else{
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            button.semanticContentAttribute = .forceRightToLeft
        }
        button.tintColor = .systemBackground


        return button
        
    }()
    
    lazy var shareWithFriendsButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(shareWithFrienButtonPrefix+"All ", for: .normal)
        button.backgroundColor = .clear
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.titleLabel?.textAlignment = .left
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        
        button.setTitleColor(.systemBackground, for: .normal)
        button.tintColor = .systemBackground
        button.backgroundColor = UIColor(named: "myTheme")


        if #available(iOS 15.0, *){
            var config = UIButton.Configuration.borderless()
            config.imagePlacement = .trailing
            config.imagePadding = 10
            button.configuration = config
        }else{
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            button.semanticContentAttribute = .forceRightToLeft
        }
        
        return button
    }()
    
    
    
    init(selectedTrip:Int){
        self.selectedTripID = selectedTrip
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Expense"
        view.backgroundColor = .systemBackground

        updateInheritedProperties()
        
        isModalInPresentation = true
        configureExpenseNameLabel()
        configureExpenseTextField()
        configurePaidByButton()
        configureShareWithFriendsButton()
    }
    
    func updateInheritedProperties(){
        let required = NSMutableAttributedString(string: "* ", attributes: [.foregroundColor : UIColor.systemRed])
        required.append(NSAttributedString(string: "Expense Name"))
        nameLabel.attributedText = required
        nameTextField.placeholder = "Enter Expense Description"
        dateLabel.text = "Expense Date"
        containerView.isUserInteractionEnabled = true
        
        datePickerView.datePickerMode = .dateAndTime
        datePickerView.maximumDate = Date()
        dateFormatter.dateFormat = "MMM dd,yyyy, h:mm a"
        selectedDateString = dateFormatter.string(from: datePickerView.date)
        shareWithFriendsID.insert(myID, at: 0)
        dateLabelBottom.isActive = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tripDetailVCRefresherDelegate?.refreshData()
    }
    
    
    func configureExpenseNameLabel(){
        containerView.addSubview(expenseNameLabel)
        expenseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            expenseNameLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor,constant: 20),
            expenseNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 10),
            expenseNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -10),
            expenseNameLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configureExpenseTextField(){
        containerView.addSubview(expenseTextField)
        expenseTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            expenseTextField.topAnchor.constraint(equalTo: expenseNameLabel.bottomAnchor, constant: 10),
            expenseTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            expenseTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            expenseTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
    }
    
    func configurePaidByButton(){
        containerView.addSubview(paidByButton)
        paidByButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            paidByButton.topAnchor.constraint(equalTo: expenseTextField.bottomAnchor,constant: 20),
            paidByButton.heightAnchor.constraint(greaterThanOrEqualToConstant:  50),
            paidByButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            paidByButton.trailingAnchor.constraint(equalTo:   containerView.trailingAnchor, constant: -10),
        ])
        paidByButton.addTarget(self, action: #selector(paidByButtonDidTapped), for: .touchUpInside)
    }
    
    func configureShareWithFriendsButton(){
        containerView.addSubview(shareWithFriendsButton)
        shareWithFriendsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            shareWithFriendsButton.topAnchor.constraint(equalTo: paidByButton.bottomAnchor,constant: 20),
            //shareWithFriendsButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            shareWithFriendsButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            shareWithFriendsButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            shareWithFriendsButton.heightAnchor.constraint(equalToConstant: 50),
            shareWithFriendsButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,constant: -10)
          
        ])
        shareWithFriendsButton.addTarget(self, action: #selector(shareWithFriendButtonDidTapped), for: .touchUpInside)
    }
    
    
    
    @objc func shareWithFriendButtonDidTapped(){
        let friendsList = FriendsListVCForSplit(needMultiselection: true, selectedTrip: selectedTripID,selectedID: shareWithFriendsID)
        friendsList.selectedFriendsDelegate = self
        let friendslistNC = UINavigationController(rootViewController: friendsList)
        friendslistNC.presentationController?.delegate = friendsList
        present(friendslistNC,animated: true)
        
    }
    
    @objc func paidByButtonDidTapped(){
        let friendsList = FriendsListVCForSplit(needMultiselection: false, selectedTrip: selectedTripID,selectedID: paidBy)
        friendsList.selectedFriendsDelegate = self
        
        let friendslistNC = UINavigationController(rootViewController: friendsList)
        friendslistNC.presentationController?.delegate = friendsList
        present(friendslistNC,animated: true)
    }
    
    override func scrollViewDidTapped() {
        nameTextField.resignFirstResponder()
        datePickerView.resignFirstResponder()
        presentedViewController?.dismiss(animated: true)
        expenseTextField.resignFirstResponder()
    }
    
    override func dateDidChanged() {
        datePickerView.resignFirstResponder()
        presentedViewController?.dismiss(animated: true)
        dateFormatter.dateFormat = "MMM dd,yyyy, h:mm a"
        selectedDateString = dateFormatter.string(from: datePickerView.date)
    }
    
    override func doneButtonDidTapped() {
        expenseTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        presentedViewController?.dismiss(animated: true)
        
        guard let paidByFriendID = paidBy.first else{
            print("***Error : while  unwrapping paid by friend ID")
            return
        }
        
        guard let expenseAmountText = expenseTextField.text else{
            print("***Error : while  unwrapping expenseAmountText")
            return
        }
        guard let expenseAmount = Double( expenseAmountText)else{
            print("***Error : while  unwrapping expenseAmount")
            return
        }
        
        self.expenseAmount = expenseAmount
        var myShare = Double()
        let perHeadAmount:Double = Double((round(100*expenseAmount/Double(shareWithFriendsID.count)))/100)
        
        var paidByname = " "
        if paidByFriendID == myID{
            paidByname = myName
            if shareWithFriendsID.contains(myID){
                myShare = perHeadAmount*Double(shareWithFriendsID.count - 1)
            }
            else{
                myShare = expenseAmount
            }
        }
        else{
            
            guard let friendName = friendNameDelegate.getFrinedName(for:paidByFriendID ) else{
                print("***Error : while  unwrapping nameFromDB")
                return
            }
            paidByname = friendName
            
            if shareWithFriendsID.contains(myID){
                let notLimitedDecimal = -expenseAmount/Double(shareWithFriendsID.count)
                myShare = Double(round(notLimitedDecimal*100)/100)
            }
            else{
                myShare = 0
            }
        }
       
        var newExpense = Expense(
            expenseID: 0,
            tripID: selectedTripID,
            expenseName: nameTextField.text!,
            paidByFriendID: paidByFriendID,
            paidByFriendName: paidByname,
            totalAmount: expenseAmount,
            myTotalShare:myShare,
            expenseDate: selectedDateString)
        
        let newExpenseID = expenseTableDelegate.insertIntoExpenseTable(expense: newExpense)
        guard let newExpenseID = newExpenseID else {
            return
        }
        newExpense.expenseID = newExpenseID
        
        if paidByFriendID == myID{
            if shareWithFriendsID.contains(myID){
                shareWithFriendsID.removeAll(where: {$0==self.myID})
            }
            insertIntoSplitShare(expID: newExpenseID, shareWithID: shareWithFriendsID, shareAmount: perHeadAmount)
           
        }else{
            if shareWithFriendsID.contains(myID){
            insertIntoSplitShare(expID: newExpenseID, shareWithID: paidBy, shareAmount: -perHeadAmount)
            }
        }
        
        insertExpenseDelegate?.insertIntoExpenseListTableView()
        groupWiseSumUpdationDelegate.updateGroupWiseSum()
        isExpenseUpdated = true
        dismiss(animated: true,completion: {
            NotificationCenter.default.post(name: .newExpenseDidAdded, object: nil, userInfo: [UserInfoKeys.newExpense:newExpense,UserInfoKeys.myDate:self.selectedDate])
        })
        
    }
    
  
    
    func insertIntoSplitShare(expID:Int,shareWithID:[String],shareAmount:Double){
        
        for id in shareWithID{
          guard  splitShareTableDBDelegate.insertIntoSplitShareTable(
            splitWith: SplitShare( expenseID: expID, shareWithFriendID: id, shareAmount: shareAmount)) else{
              print("***Error:while insert into splitshare")
              return
          }
        }
        
    }
    
    override func cancelButtonDidTapped() {
        expenseTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
       
        if (nameTextField.text?.isEmpty ?? true) && (expenseTextField.text?.isEmpty ?? true){
            dismiss(animated: true, completion: nil)

        }
        else{
            let actionSheet = UIAlertController(title: nil, message: "Are you sure you want to discard this new expesene detail?", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Keep Editing", style: .cancel, handler: nil))
            actionSheet.addAction(UIAlertAction(title: "Discard Changes", style: .destructive, handler: {_ in
                self.dismiss(animated: true, completion: nil)
            }))
            
            actionSheet.popoverPresentationController?.sourceView = self.view
            let xOrigin = 0
            let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
            actionSheet.popoverPresentationController?.sourceRect = popoverRect
            actionSheet.popoverPresentationController?.permittedArrowDirections = .up
            present(actionSheet,animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.resignFirstResponder()
        presentedViewController?.dismiss(animated: true)
        expenseTextField.resignFirstResponder()
    }
}


//overriding
extension InsertExpenseViewController{
    override func textFieldDidEndEditing(_ textField: UITextField) {
        if nameTextField.isContainText() && expenseTextField.isContainText()
        {doneBarButton.isEnabled = true }
        else{ doneBarButton.isEnabled = false }
    }
    
    override func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == nameTextField{
        nameCharecterCountLabel.text = "0/\(maxCharacterInTextField)"
        }
        doneBarButton.isEnabled = false
        return true
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxCharacterInExpenseField = InsertExpenseViewController.ExpenseAmountCharecterLimit

        maxCharacterInTextField = InsertExpenseViewController.NameCharactersLimit

        guard let currentText = textField.text as NSString? else{return false}
        let replacementString = currentText.replacingCharacters(in: range, with: string)
        
        if replacementString.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            if textField == nameTextField{
                if expenseTextField.isContainText() && replacementString.count <= maxCharacterInTextField{
                    doneBarButton.isEnabled = true
                }
                else{
                    doneBarButton.isEnabled = false
                }
            }
            
            if textField == expenseTextField{
                if replacementString.trimmingCharacters(in: .letters) != ""{
                    if nameTextField.isContainText(){
                        doneBarButton.isEnabled = true
                    }
                    else{
                        doneBarButton.isEnabled = false
                    }
                }
            }
        }
        else{doneBarButton.isEnabled = false}
       
        var result = false
        

        if textField == expenseTextField{
            let allowedCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: Locale.current.decimalSeparator ?? "."))
            let characterSet = CharacterSet(charactersIn: string)
            let isNumeric = allowedCharacters.isSuperset(of: characterSet)
            if Double(replacementString) == nil {
                if replacementString != ""{
                throwWarningToUser(viewController: self.presentedViewController ?? self, title: "Error", errorMessage: "You are tring to enter Invalid number \'\(replacementString)\'")
                
                    return false}
            }
            return (replacementString.count <= maxCharacterInExpenseField) && isNumeric

        }
        else{
            result  = replacementString.count <= maxCharacterInTextField
            if result{
                nameCharecterCountLabel.text = "\(replacementString.count )/\(maxCharacterInTextField)"
            }
        }
        
        return result
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField && !(textField.text?.isEmpty ?? true){
            textField.resignFirstResponder()
            expenseTextField.becomeFirstResponder()
            return true
        }else if textField == expenseTextField{
            if doneBarButton.isEnabled{
                doneButtonDidTapped()
                return true
            }
            else{
                nameTextField.becomeFirstResponder()
                return true
            }
        }
        return false
    }
}

extension InsertExpenseViewController:SelectedFriendsForExpenseDelegate{
    func updateSelectedFriends(id:[String],isMultiselected:Bool){
        if isMultiselected{
            shareWithFriendsID = []
            shareWithFriendsID.append(contentsOf: id)

            
            
            if entireFriendsID.count == id.count{
                shareWithFriendsButton.setTitle(shareWithFrienButtonPrefix+"All  ", for: .normal)
            }
            else{
                shareWithFriendsButton.setTitle(shareWithFrienButtonPrefix+"\(shareWithFriendsID.count)"+"  ", for: .normal)
                if shareWithFriendsID.count == 1 && shareWithFriendsID[0] == "0"{
                    shareWithFriendsButton.setTitle(shareWithFrienButtonPrefix+"None"+"  ", for: .normal)
                }
            }
            
        }
        else{
            paidBy = id
            guard let paidBYId = id.first else{
                return
            }
            if paidBYId == myID{
                paidByButton.setTitle(paidByButtonPrefix+myName, for: .normal)
            }
            else{
                guard let name = friendNameDelegate.getFrinedName(for: paidBYId) else{
                    
                    return
                }
                paidByButton.setTitle(paidByButtonPrefix+name+" ", for: .normal)
            }
        }
    }
}

extension InsertExpenseViewController{
    override func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        self.cancelButtonDidTapped()
    }
}
