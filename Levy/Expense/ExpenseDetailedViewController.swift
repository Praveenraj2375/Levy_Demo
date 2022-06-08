//
//  ExpenseDetailedViewController.swift
//  Levy
//
//  Created by Praveenraj T on 23/03/22.
//

import UIKit

protocol ExpenseUpdationDelegate:AnyObject{
    func updateExpenseDetail(expense:Expense,amount:Double)
}

class ExpenseDetailedViewController: UIViewController {
    
    var selectedExp :Expense
    var selectedIndexPath = IndexPath()
    
    let splitShareTableDBDelegate :SplitShareTableDBDelegate = UseCase()
    let deleteSplitDetailDelegate:DeleteSplitDetailDelegate = UseCase()
    weak var expenseUpdationDelegate:ExpenseUpdationDelegate?
    
    var amountNeedsToBePaid = Double(0)
    weak var actionToEnable : UIAlertAction?

    
    private lazy var expenseDetailTableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    let formatter :NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()
    
    private lazy var aboutExpeseData: [[String]] = [
        [ "Expense Name","Paid By","My Share","Total"],
        [
            selectedExp.expenseName,
            selectedExp.paidByFriendName,
            currencyFormatter().string(from:  selectedExp.myTotalShare as NSNumber) ?? " ",
            currencyFormatter().string(from:  selectedExp.totalAmount as NSNumber) ?? " "
            
        ]
    ]
    var splitDetail = [SplitShare]()
    
    init(expense:Expense){
        selectedExp = expense
        super.init(nibName: nil, bundle: nil)
        title = expense.expenseName
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureTripDetailTableView()
        bringDataForUI()
        navigationItem.largeTitleDisplayMode = .never
        NotificationCenter.default.addObserver(self, selector: #selector(expenseDidDeleted(_:)), name: .expenseDidDeleted, object: nil)

    }
    @objc func expenseDidDeleted(_ notification:Notification){
        guard let expId = notification.userInfo?[UserInfoKeys.expenseID] as? Int else{
            return
        }
        
        if expId == selectedExp.expenseID{
            navigationController?.popViewController(animated: true)
        }
        
    }
    override func bringDataForUI() {
        splitDetail = splitShareTableDBDelegate.getSplitShareDetail(for: selectedExp.expenseID)
        updateExpenseInfo()
        expenseDetailTableView.reloadData()
        
    }
    
    func updateExpenseInfo(){
        if selectedExp.myTotalShare >= 0{
            aboutExpeseData[0][2] = "To Be Received"
        }else{
            aboutExpeseData[0][2] = "To Be Paid"
        }
        aboutExpeseData[1][2] = currencyFormatter().string(from: selectedExp.myTotalShare.magnitude as NSNumber) ?? "0"
                        
    }
    
    func configureTripDetailTableView(){
        view.addSubview(expenseDetailTableView)
        
        expenseDetailTableView.delegate = self
        expenseDetailTableView.dataSource = self
        
        expenseDetailTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            expenseDetailTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            expenseDetailTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            expenseDetailTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            expenseDetailTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
        ])
        
        expenseDetailTableView.register(AboutTableViewCell.self, forCellReuseIdentifier: AboutTableViewCell.identifier)
        expenseDetailTableView.register(ExpesenceDetailCell.self, forCellReuseIdentifier: ExpesenceDetailCell.identifier)
        expenseDetailTableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderView.identifier)
    }
    
    
}

extension ExpenseDetailedViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier) as? HeaderView
        guard let view = view else{
            print("***Error header unwrap error")
            return UITableViewHeaderFooterView()
        }
        switch section{
        case 0: view.titleLabel.text = "About Expense"
        case 1: view.titleLabel.text = "Detailed Expense "
        default: view.titleLabel.text = " "
        }
        
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            guard let rowCount = aboutExpeseData.first?.count else{
                print("*** error")
                return 0
            }
            return rowCount
        }
        else{
            return splitDetail.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 40
        }
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: AboutTableViewCell.identifier) as? AboutTableViewCell
            guard let cell = cell else{
                print("*** errror-unwraping cell")
                return UITableViewCell()
            }
            cell.setDetailNameLabel(with: aboutExpeseData[0][indexPath.row])
            cell.setDetailValueLabel(with: aboutExpeseData[1][indexPath.row])
            
            cell.isUserInteractionEnabled = false
//            if indexPath.row == 2{
//                cell.setDetailValueLabel(with:  selectedExp.myTotalShare)
//            }
            
            return cell
        }
        else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier:ExpesenceDetailCell.identifier) as? ExpesenceDetailCell
            
            guard let cell = cell else{
                print("cell creation error - tripdetailed vc")
                return UITableViewCell()
            }
            if !splitDetail.isEmpty{
                
                cell.bottomLeftButton.isHidden = true
                cell.bottomLeftButton.isEnabled = false
                cell.bottomLeftButtonHeightAnchor.isActive = false
                cell.bottomLeftButtonZeroHeight.isActive = true
                
                cell.setTitlelabel(with:  splitDetail[indexPath.row].friendName)
                cell.setTopRightLable(with: splitDetail[indexPath.row].shareAmount)
                
                
                if splitDetail[indexPath.row].shareAmount == 0{
                    cell.updateUIForAllSettledState()
                }
                else{
                    cell.updateUIForSettleState()
                }
            }

            cell.selectionStyle = .none
            cell.settleupButtonDelegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0{
            return nil
        }
        var isHaveDues = false
        
        if splitDetail[indexPath.row].shareAmount != 0{
            isHaveDues = true
        }
        
        let alert = UIAlertController(title: "⚠ Warning", message: "Are you sure want to remove split detail permanently ?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style:.destructive , handler: {_ in
            self.deleteSplitDetailDelegate.deleteSplitDetail(for:self.splitDetail[indexPath.row].splitID)
            self.splitDetail.remove(at: indexPath.row)
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
            throwWarningToUser(viewController: self, title: "Expense have uncleared dues", errorMessage: "Please clear all dues before deleting expense detail.")
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

extension ExpenseDetailedViewController:UITextFieldDelegate{
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

extension ExpenseDetailedViewController:SettleupButtonDelegate{
    @objc func textChanged(_ sender:UITextField) {
        self.actionToEnable?.isEnabled  = (sender.text! != "")
    }
    
    func settleupButtonDidTappd(at cell: UITableViewCell) {
        guard let index = expenseDetailTableView.indexPath(for: cell) else{
            print("Error while getting index")
            return
        }
        
        amountNeedsToBePaid = splitDetail[index.row].shareAmount.magnitude
        let alert = UIAlertController(title: "", message: "Enter Settle Up Amount", preferredStyle: .alert)
        alert.popoverPresentationController?.sourceView = self.view
        
//        let popoverRect = CGRect(x: 0, y: 0, width: 1, height: 1)
//        alert.popoverPresentationController?.sourceRect = popoverRect
//        alert.popoverPresentationController?.permittedArrowDirections = .any
        alert.addTextField(configurationHandler: {newText in
            newText.text = self.amountNeedsToBePaid.description
            newText.placeholder = "Enter Settle Up Amount"
            newText.keyboardType = .decimalPad
            newText.delegate = self
            newText.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "OK", style: .default,handler: { [self]_ in
            alert.textFields?.first?.resignFirstResponder()
            guard let amountText =  alert.textFields?.first?.text else{
                throwWarningToUser(viewController: self, title: "Error", errorMessage: "Something went wrong \nplease contact admin")
                return
            }
            let formatter = NumberFormatter()
            
            formatter.decimalSeparator = Locale.current.decimalSeparator
            
            guard let paidAmount = formatter.number(from: amountText) as? Double else{
                throwWarningToUser(viewController: self, title: "Error", errorMessage: "Invalid Number ")
                
                return}
            var settledAmount = paidAmount
            
            if splitDetail[index.row].shareAmount <= 0 {
                settledAmount = -settledAmount
            }
            
            let isUpdated = self.splitShareTableDBDelegate.updateSplitShare(
                expense: self.selectedExp,  friendID: self.splitDetail[index.row].shareWithFriendID, amount: -settledAmount)
            if !isUpdated{
                throwWarningToUser(viewController: self, title: "Error", errorMessage: "Something went wrong")
            }
            
            
            self.splitDetail[index.row].shareAmount -= settledAmount
            self.selectedExp.myTotalShare -= settledAmount
            
            updateExpenseInfo()
            self.expenseDetailTableView.reloadRows(at: [IndexPath(row: index.row, section: 1),IndexPath(row: 2, section: 0)], with: .automatic)
            
            self.expenseUpdationDelegate?.updateExpenseDetail(expense:self.selectedExp,amount:settledAmount)
            isExpenseUpdated = true
            
            NotificationCenter.default.post(name: .expenseDidSettled, object: nil,userInfo: [UserInfoKeys.expenseID:selectedExp.expenseID,UserInfoKeys.settledAmount:settledAmount])
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.actionToEnable = okAction
        //okAction.isEnabled = false
        alert.preferredAction = okAction
        present(alert,animated: true)
        
    }
}
