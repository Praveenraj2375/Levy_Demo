//
//  UtilityFile.swift
//  Levy
//
//  Created by Praveenraj T on 31/03/22.
//

import Foundation
import UIKit
import Network
let myThemeColor = UIColor(named: "myTheme")
let secondaryCustomColor = UIColor(red: 200/255, green: 157/255, blue: 54/255, alpha: 1)
let myShadowColor = UIColor(named: "ShadowColor")?.cgColor

let userDefaults = UserDefaults(suiteName: "com.levy.userDefaults")
var isNewTripAdded = false
var isNewFriendAddedOrRemoved = false
var isExpenseUpdated = false
let urlConfig = URLSessionConfiguration.default
var myURLSession:URLSession? = URLSession(configuration: urlConfig)

extension UserDefaults{
    var tripListSortKey:String{
        get{ return "tripSortKey"}
    }
}


func throwWarningToUser(viewController:UIViewController,title:String,errorMessage:String){
    let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default)
    alert.addAction(okAction)
    viewController.present(alert, animated: true)
}


func currencyFormatter()->NumberFormatter{
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 2
    return formatter
}

let imageCache:NSCache<AnyObject,UIImage> = {
    let cache = NSCache<AnyObject,UIImage>()
    cache.countLimit = 30
    cache.totalCostLimit = 1024*1024*100
    return cache
}()


func emptySearchResult(for tableView:UITableView,in view:UIView){
    
    let myview = UIView()
    tableView.backgroundView = myview
    myview.backgroundColor = .systemGray5
    myview.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
        myview.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
        myview.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
        myview.topAnchor.constraint(equalTo: tableView.topAnchor),
        myview.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
    ])
    
    let label = UILabel()
    label.text = "No Result"
    label.font = UIFont.boldSystemFont(ofSize: 30)
    myview.addSubview(label)
    label.textColor = .systemGray3
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
    label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
    label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
}


func createMandatoryText(for string:String)->NSMutableAttributedString{
    let requiredSymbol = NSMutableAttributedString(string: "* ", attributes: [.foregroundColor : UIColor.systemRed])
    requiredSymbol.append(NSAttributedString(string: string))
    
    return requiredSymbol
}
