//
//  LevyDB.swift
//  Levy
//
//  Created by Praveenraj T on 12/04/22.
//

import Foundation
class LevyDB{
    static let dbFile = "LevyDB.sqlite3"
    
    static let TripListTableName = "TripListTable"
    static let GroupDetailsTableName = "GroupDetailsTable"
    static let FriendWiseExpenseTableName = "FriendsWiseExpenseTable"
    static let SplitShareTableName = "SplitShareTable"
    static let ExpenseListTableName = "ExpenseList"
    static let FriendsInGroupTableName = "FriendsInGroup"
    static let FriendsInTripTableName = "FriendsInTrip"
    
    enum TripListTableColumn{
        static let TripID = "TripID"
        static let TripName = "TripName"
        static let StartDate = "StartDate"
        static let TotalReturn = "TotalReturn"
        static let GroupID = "GroupID"
    }
    
    enum FriendWiseExpenseTableColumn{
        static let  FriendId = "FriendId"
        static let  FriendName = "FriendName"
        static let  PhoneNumber = "PhoneNumber"
        static let  TotalReturn = "TotalReturn"
    }
    
    enum GroupDetailsTableColumn{
        static let GroupID = "GroupID"
        static let GroupName = "GroupName"
        static let GroupDescription = "GroupDescription"
        static let GroupWiseShare = "ShareAmount"
        static let GroupImageURLString = "GroupImageURL"
        
    }
    
    enum ExpenseListTableColumn{
        static let ExpenseID = "ExpenseID"
        static let TripID = "TripID "
        static let ExpenseName = "ExpenseName"
        static let PaidByFriendID = "PaidByFriendID"
        static let TotalAmount = "TotalAmount"
        static let MyTotalShare = "MyTotalShare"
        static let expenseDate = "expenseDate"
    }
    
    enum SplitShareTableColumn{
        static let SplitID            = "SplitID"
        static let ExpenseID          = "ExpenseID"
        static let ShareWithFriendID  = "ShareWithFriendID"
        static let ShareAmount        = "ShareAmount"
    }
    
    enum FriendsInGroupTableColumn{
        static let FriendInGroupID  = "FriendInGroupID"
        static let GroupID          = "GroupID"
        static let FriendID         = "FriendID"
    }
    
    enum FriendsInTripTableColumn{
        static let FriendIDInTripTableKey  = "FriendIDInTripTableKey"
        static let TripID          = "TripID"
        static let FriendID        = "FriendID"
    }
    
    
}
