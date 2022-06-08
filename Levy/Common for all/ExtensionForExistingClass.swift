//
//  ExtensionForExistingClass.swift
//  Levy
//
//  Created by Praveenraj T on 29/03/22.
//

import Foundation
import UIKit


extension UITextField{
    func isContainText()->Bool{
        if (text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""){
            return true
        }
        else{
            return false
        }
    }
    
}


extension UILabel {
    func setNumericValue(value:Double) {
        let formatter = currencyFormatter()
        if value == 0{
            text = "All Settled"
            textColor = .systemGreen
            return
        }
        if value > 0 {
            formatter.positivePrefix =  formatter.currencySymbol
            let atrString = NSMutableAttributedString(string: "You owed\n", attributes: [.font:UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),.foregroundColor:UIColor.systemGreen])
            
            if let str = formatter.string(from: value as NSNumber){
                atrString.append(NSAttributedString(string:str,attributes: [.font:UIFont.boldSystemFont(ofSize: 20),.foregroundColor:UIColor.systemGreen]))
                attributedText = atrString
            }
        }
        else{
            
            formatter.negativePrefix = formatter.currencySymbol
            let atrString = NSMutableAttributedString(string: "You're owing\n", attributes: [.font:UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),.foregroundColor:UIColor.systemRed])
            if let str = formatter.string(from: value as NSNumber){
                atrString.append(NSAttributedString(string:str,attributes: [.font:UIFont.boldSystemFont(ofSize: 20),.foregroundColor:UIColor.systemRed]))
                attributedText = atrString
            }        }
    }
}



extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

extension UIViewController{
   @objc func bringDataForUI(){
        
    }
}




extension Set {
    mutating func insert<S>(contentsOf:S)where S : Sequence, Element == S.Element{
        contentsOf.forEach({item in
            self.insert(item)
        })
    }
    
    mutating func remove(item:Element){
        if let index = firstIndex(of: item){
            remove(at: index)
        }
    }
    
}
extension Notification.Name{
    static let newTripDidAdded = Notification.Name("newTripDidAdded")
    
    static let newFriendDidAdded = Notification.Name("newFriendDidAddedf")
    static let friendDidRemoved = Notification.Name("friendDidRemoved")
    static let tripDidDeleted = Notification.Name("tripDidDeleted")
    static let updateTripDetail = Notification.Name("updateTripDetail")
    static let newExpenseDidAdded = Notification.Name("newExpenseDidAdded")
    static let expenseDidSettled = Notification.Name("expenseDidSettled")
    static let expenseDidDeleted = Notification.Name("expenseDidDeleted")

}
struct UserInfoKeys{
    static let  indexPath = "indexPath"
    static let myDate = "Date"
    
    static let tripID = "tripID"
    static let expenseID = "expenseID"
    static let newTrip = "newTrip"
    static let updateTrip = "updateTrip"
    static let newFriend = "newFriend"
    static let friendID = "FreindID"
    static let friendDetail = "FriendDetail"
    static let newExpense = "newExpense"
    static let updatedExpense = "updatedExpense"
    static let settledAmount = "settledAmount"
}
