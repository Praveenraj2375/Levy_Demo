//
//  UseCase.swift
//  Levy
//
//  Created by Praveenraj T on 08/03/22.
//

import Foundation
import UIKit

protocol TripListDelegate{
    func getEntireTripListFromDB(limit:Int ,offset:Int,sortBy:String )->[TripDetails]
    func insertNewTripIntoDB(tripName name:String,date:String,groupID:Int)-> TripDetails?
    func getEntireTripListFromDB(limit:Int ,offset:Int,sortBy:String,onCompletion: ([TripDetails])->Void)
}

protocol TripDetailDBDelegate{
    func inserIntoFriendWiseExpense(friend:FriendWiseExpense)->Bool?
    func insertIntoFriendsInTrip(value:FriendsInTrip)->Bool
    func getEntireFriendWiseExpenseFromDB(limit:Int ,offset:Int,sortBy:String )->[FriendWiseExpense]
    func getEntireFrindsInTripFromDB(for tripID:Int)->[FriendsInTrip]
    
    
}

protocol FriendNameFromDBDelegate{
    func getFrinedName(for ID:String)->String?
}

protocol GroupNameFromDBDelegate{
    func getGroupName(for ID:UInt)->String?
}

protocol ExpenseTableDelegate{
    func insertIntoExpenseTable(expense:Expense)->Int?
    func getEntireExpenseListFromDB(for tripID:Int)->[Expense]?
}

protocol SplitShareTableDBDelegate{
    func insertIntoSplitShareTable(splitWith:SplitShare)->Bool
    func getSplitShareDetail(for expenseID:Int)->[SplitShare]
    func updateSplitShare(expense:Expense,friendID:String,amount:Double)->Bool
    
}

protocol FriendWiseExpDBDelegate{
    func getTripListFromDB(for friendID: String)->[TripDetails]
}


protocol SettleUpFromFreindWiseExpDelegate{
    func settledFully(friendID:String)
    func settledPartialAmount(frindID:String,paidAmount:Double)
}

protocol SettleUpFromFriendWiseDetailedDelegate{
    func settledUp(friendID:String,tripID:Int,amount:Double)
}

protocol SelectedFriendWiseExpDelegate{
    func getFriendwiseExp(friendID:String)->FriendWiseExpense?
}

protocol SelectedTripDelegate{
    func getTripDetailFor(tripID:Int)->TripDetails?
}

protocol SelectedGroupDelegate{
    func getGroupDetail(for groupID:Int)->GroupDetails?
}

protocol GroupDBDelegate{
    func insertIntoGroupDetails(group:GroupDetails)->Int?
    func insertIntoFriendsInGroup(friend:FriendsInGroup)
    func getGroupDetailList()->[GroupDetails]
}

protocol GroupDetailDBDelegate{
    func getTripDetailForGroup(groupID:Int)->[TripDetails]
    func getFriendsInGroup(for groupID:Int)->[FriendsInGroup]
}

protocol GroupWiseSumUpdationDelegate{
    func updateGroupWiseSum()
}


protocol EntriesCountDelegate{
    func getEntriesCountInFriendsWiseExpTable()->Int
    func getEntriesCountInTripListTable()->Int
}

protocol AppSpcificContactDelegate{
    func readFromFriendWiseExpTable(existedID:[String])->[ContactDetail]
}

protocol SearchResultFromDBDelegate{
    func searchInFriendWiseTabel(for text:String,dataLimit:Int,dataOffset:Int)->(Int, [FriendWiseExpense])
    func searchInTirpListTabel(for text:String,dataLimit:Int,dataOffset:Int)->(Int,[TripDetails])
}

protocol TotalReturnDelegate{
    func getTotalReturn()->Double
    func getTotalOwedAmount()->Double
    func getTotalOwingAmount()->Double
}


protocol NetworkHelperDelegate{
    func getImage(for url:String,searchText:String,cache:NSCache<AnyObject, AnyObject>?,onCompletion:@escaping(UIImage?,LevyError?,String,Bool?)->Void)
}
//extension NetworkHelperDelegate{
//    func getImage(for url:String,searchText:String="",cache:NSCache<AnyObject, AnyObject>? = nil,onCompletion:@escaping(UIImage?,LevyError?,String,Bool?)->Void){
//        
//    }
//}


protocol FetchImageAPIDelegate{
    func fetchImage(searchFor searchText:String,page:Int, totalPages:Int,totalResult:Int,previousResult:Int ,onCompletion:@escaping (Error?,APIResponse?)->Void)
}


protocol DeleteTripDelegate{
    func deleteTrip(for tripid:Int)
}

protocol DeleteExpenseDelegate{
    func deleteExpense(for expenseID:Int)
}

protocol DeleteSplitDetailDelegate{
    func deleteSplitDetail(for splitID:Int)
}

protocol DeleteFriendDetailDelegate{
    func deleteFriendDetail(for friendID:String)
}

protocol FriendsDuesDelegate{
    func isFriendHaveDues(for friendID: String,in tripID:Int,groupID:Int) -> Bool
}
extension FriendsDuesDelegate{
    func isFriendHaveDues(for friendID: String,in tripID:Int = 0,groupID:Int = 0) -> Bool{return false}
}

protocol DeleteFriendFromTripDelegate{
    func deleteFriendFromTrip(friendID:String,from tripID:Int)
}
protocol DeleteFriendsFromGroupDelegate{
    func deleteFriendFromGroup(friendID:String,from groupID:Int)
}

protocol DeleteGroupDelegate{
    func deleteGroup(for groupID:Int)
}

protocol FriendIDDelegate{
    func getFriendsID()->[String]
}


class UseCase:TripListDelegate{
    
    func formatDateFromMMtoMMM(dateAsString:String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: dateAsString){
            dateFormatter.dateFormat = "MMM\ndd\nyyyy"
            return dateFormatter.string(from: date)
        }
        else{
            return dateAsString
        }
    }
    
    func getEntireTripListFromDB(limit:Int ,offset:Int,sortBy:String )->[TripDetails]{
        
        var condition = ""
        
        switch sortBy{
        case SortViewController.dateAse:
            condition = "ORDER BY \(LevyDB.TripListTableColumn.StartDate) ASC,\(LevyDB.TripListTableColumn.TripName) ASC,\(LevyDB.TripListTableColumn.TotalReturn) = 0,\(LevyDB.TripListTableColumn.TotalReturn) ASC"
            
        case SortViewController.dateDesc:
            condition = "ORDER BY \(LevyDB.TripListTableColumn.StartDate) DESC,\(LevyDB.TripListTableColumn.TripName) ASC,\(LevyDB.TripListTableColumn.TotalReturn) = 0,\(LevyDB.TripListTableColumn.TotalReturn) ASC"
            
        case SortViewController.nameAse:
            condition =  "ORDER BY \(LevyDB.TripListTableColumn.TripName) ASC,\(LevyDB.TripListTableColumn.StartDate) ASC,\(LevyDB.TripListTableColumn.TotalReturn) = 0,\(LevyDB.TripListTableColumn.TotalReturn) ASC"
        
        case SortViewController.nameDesc:
            condition = "ORDER BY \(LevyDB.TripListTableColumn.TripName) DESC,\(LevyDB.TripListTableColumn.StartDate) ASC,\(LevyDB.TripListTableColumn.TotalReturn) = 0,\(LevyDB.TripListTableColumn.TotalReturn) ASC"
            
        case SortViewController.amountAsc:
            condition = "ORDER BY \(LevyDB.TripListTableColumn.TotalReturn) = 0, \(LevyDB.TripListTableColumn.TotalReturn) ASC,\(LevyDB.TripListTableColumn.TripName) ASC,\(LevyDB.TripListTableColumn.StartDate) ASC"
            
        case SortViewController.amountDesc:
            condition = "ORDER BY \(LevyDB.TripListTableColumn.TotalReturn) = 0, \(LevyDB.TripListTableColumn.TotalReturn) DESC,\(LevyDB.TripListTableColumn.TripName) ASC,\(LevyDB.TripListTableColumn.StartDate) DESC"
        default: break
        }
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        var result = DBHelper.shared.readFromTripListTable(limit: limit, offset: offset ,condition:condition)
        DBHelper.shared.closeDatabase()
        
        for trip in 0..<result.count{
            result[trip].startDate = formatDateFromMMtoMMM(dateAsString: result[trip].startDate)
        }
        
        return result
    }
    
    func getEntireTripListFromDB(limit:Int ,offset:Int,sortBy:String,onCompletion: ([TripDetails])->Void){
        
     
            var condition = ""
            
            switch sortBy{
            case SortViewController.dateAse: condition = "ORDER BY \(LevyDB.TripListTableColumn.StartDate) ASC,\(LevyDB.TripListTableColumn.TripName) ASC,\(LevyDB.TripListTableColumn.TotalReturn) = 0,\(LevyDB.TripListTableColumn.TotalReturn) ASC"
                
            case SortViewController.dateDesc: condition = "ORDER BY \(LevyDB.TripListTableColumn.StartDate) DESC,\(LevyDB.TripListTableColumn.TripName) ASC,\(LevyDB.TripListTableColumn.TotalReturn) = 0,\(LevyDB.TripListTableColumn.TotalReturn) ASC"
                
            case SortViewController.nameAse: condition =  "ORDER BY \(LevyDB.TripListTableColumn.TripName) ASC,\(LevyDB.TripListTableColumn.StartDate) ASC,\(LevyDB.TripListTableColumn.TotalReturn) = 0,\(LevyDB.TripListTableColumn.TotalReturn) ASC"
            
            case SortViewController.nameDesc:condition = "ORDER BY \(LevyDB.TripListTableColumn.TripName) DESC,\(LevyDB.TripListTableColumn.StartDate) ASC,\(LevyDB.TripListTableColumn.TotalReturn) = 0,\(LevyDB.TripListTableColumn.TotalReturn) ASC"
                
            case SortViewController.amountAsc:condition = "ORDER BY \(LevyDB.TripListTableColumn.TotalReturn) = 0, \(LevyDB.TripListTableColumn.TotalReturn) ASC,\(LevyDB.TripListTableColumn.TripName) ASC,\(LevyDB.TripListTableColumn.StartDate) ASC"
                
            case SortViewController.amountDesc:condition = "ORDER BY \(LevyDB.TripListTableColumn.TotalReturn) = 0, \(LevyDB.TripListTableColumn.TotalReturn) DESC,\(LevyDB.TripListTableColumn.TripName) ASC,\(LevyDB.TripListTableColumn.StartDate) ASC"
            default: break
                
            }
            //let db = DBHelper()
            //db.openDataBase()
        //db.concurrentConnection = db.openDataBase()
            DBHelper.shared.db = DBHelper.shared.openDataBase()

        var result = DBHelper.shared.readFromTripListTable(limit: limit, offset: offset, condition:condition)
        DBHelper.shared.closeDatabase()
        
        for trip in 0..<result.count{
            result[trip].startDate = formatDateFromMMtoMMM(dateAsString: result[trip].startDate)
        }
        
        //return result


        onCompletion(result)
            

        
    }
    
    func insertNewTripIntoDB(tripName name:String,date:String,groupID:Int) -> TripDetails? {
        let query = "INSERT INTO \(LevyDB.TripListTableName) (\(LevyDB.TripListTableColumn.TripName),\(LevyDB.TripListTableColumn.StartDate),\(LevyDB.TripListTableColumn.GroupID)) VALUES (\'\(name)\',\'\(date)\',\(groupID));"
           // print("***\n",query)
        //DBHelper.shared.closeDatabase()
        DBHelper.shared.db = DBHelper.shared.openDataBase()
       guard let insertedRow = DBHelper.shared.insert(query: query, tableName: LevyDB.TripListTableName) else{
           print("error: while inserting in \(LevyDB.TripListTableName)")
           DBHelper.shared.closeDatabase()
            return nil
        }
        DBHelper.shared.closeDatabase()
        
        //DBHelper.shared.db = DBHelper.shared.openDataBase()
        let result =  TripDetails(tripID: insertedRow, tripName: name , startDate: date,groupID: UInt(groupID))
        //DBHelper.shared.closeDatabase()
        
        return result
    }
    
}

extension UseCase:TripDetailDBDelegate{
    
    
    func getEntireFrindsInTripFromDB(for tripID:Int = 0) -> [FriendsInTrip]{
        var condition = " "
        if tripID != 0{
            condition = "WHERE \(LevyDB.FriendsInTripTableColumn.TripID) = \(tripID) ORDER BY \(LevyDB.FriendWiseExpenseTableColumn.FriendName)"
        }
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        let result = DBHelper.shared.readFromFriendsInTripTable(condition: condition)
        DBHelper.shared.closeDatabase()
        return result
    }
   
    func getEntireFriendWiseExpenseFromDB(limit: Int = 20, offset: Int,sortBy:String = "")->[FriendWiseExpense] {
        let ascendingOrder = "ASC"
        let descendingOrder = "DESC"
        
        var condition = ""
        
        switch sortBy{

        case SortViewController.nameAse: condition = "ORDER BY \(LevyDB.FriendWiseExpenseTableColumn.FriendName) \(ascendingOrder),\(LevyDB.FriendWiseExpenseTableColumn.TotalReturn) = 0,\(LevyDB.FriendWiseExpenseTableColumn.TotalReturn)"
        
        case SortViewController.nameDesc:condition = "ORDER BY \(LevyDB.FriendWiseExpenseTableColumn.FriendName) \(descendingOrder),\(LevyDB.FriendWiseExpenseTableColumn.TotalReturn) = 0,\(LevyDB.FriendWiseExpenseTableColumn.TotalReturn)"
            
        case SortViewController.amountAsc:condition = "ORDER BY \(LevyDB.FriendWiseExpenseTableColumn.TotalReturn) = 0, \(LevyDB.FriendWiseExpenseTableColumn.TotalReturn) \(ascendingOrder),\(LevyDB.FriendWiseExpenseTableColumn.FriendName) \(ascendingOrder)"
            
        case SortViewController.amountDesc:condition = "ORDER BY \(LevyDB.FriendWiseExpenseTableColumn.TotalReturn) = 0,\(LevyDB.FriendWiseExpenseTableColumn.TotalReturn)  \(descendingOrder),\(LevyDB.FriendWiseExpenseTableColumn.FriendName) \(ascendingOrder)"
        default: break
            
        }
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateFriendWiseShare()
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        let result = DBHelper.shared.readFromFriendsWiseExpenseTable(condition:condition, limit: limit, offset: offset)
        DBHelper.shared.closeDatabase()
        return result
    }
    
    func inserIntoFriendWiseExpense(friend: FriendWiseExpense) ->Bool?{
        let query = "INSERT OR IGNORE INTO \(LevyDB.FriendWiseExpenseTableName) (\(LevyDB.FriendWiseExpenseTableColumn.FriendId),\(LevyDB.FriendWiseExpenseTableColumn.FriendName),\(LevyDB.FriendWiseExpenseTableColumn.PhoneNumber)) VALUES (\'\(friend.friendID)\',\'\(friend.name)\',\'\(friend.phoneNumber)\');"
        print("***\n",query)
       
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        guard DBHelper.shared.insert(query: query, tableName: LevyDB.TripListTableName) != nil else{
            print("error: while inserting in \(LevyDB.FriendWiseExpenseTableName)")
            DBHelper.shared.closeDatabase()
             return nil
         }
        DBHelper.shared.closeDatabase()
        
        return true

    }
    
    func insertIntoFriendsInTrip(value: FriendsInTrip) ->Bool{
        let query = "INSERT INTO \(LevyDB.FriendsInTripTableName) (\(LevyDB.FriendsInTripTableColumn.FriendID),\(LevyDB.FriendsInTripTableColumn.TripID)) VALUES (\'\(value.friendID)\',\(value.tripID));"
        DBHelper.shared.db = DBHelper.shared.openDataBase()

        guard DBHelper.shared.insert(query: query, tableName: LevyDB.FriendsInTripTableName) != nil else{
            print("error: while inserting in \(LevyDB.FriendsInTripTableName)")
            DBHelper.shared.closeDatabase()

             return false
         }
        DBHelper.shared.closeDatabase()
        return true
        
    }
}

extension UseCase:FriendNameFromDBDelegate{
    func getFrinedName(for ID: String)->String?{
        let result = DBHelper.shared.getNameForFriendID(id: ID)
        return result
    }
}

extension UseCase:ExpenseTableDelegate{
    func getEntireExpenseListFromDB(for tripID: Int) -> [Expense]? {
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        var result =  DBHelper.shared.readFromExpenseTable(tripID: tripID)
        DBHelper.shared.closeDatabase()
        
        for index in 0..<result.count{
            result[index].expenseDate = formatDateFromMMtoMMM(dateAsString: result[index].expenseDate)
        }
        
        return result
    }
    
    func insertIntoExpenseTable(expense: Expense) -> Int? {
       
        let query = """
INSERT OR IGNORE INTO \(LevyDB.ExpenseListTableName) (\(LevyDB.ExpenseListTableColumn.TripID),\(LevyDB.ExpenseListTableColumn.expenseDate),\(LevyDB.ExpenseListTableColumn.ExpenseName),\(LevyDB.ExpenseListTableColumn.PaidByFriendID),\(LevyDB.ExpenseListTableColumn.TotalAmount),\(LevyDB.ExpenseListTableColumn.MyTotalShare))
VALUES (\(expense.tripID),\'\(expense.expenseDate)\',\'\(expense.expenseName)\',\'\(expense.paidByFriendID)\',\(expense.totalAmount),\(expense.myTotalShare));
"""
        //print("***\n",query)
        //DBHelper.shared.closeDatabase()
        DBHelper.shared.db  = DBHelper.shared.openDataBase()
       
        guard let expID = DBHelper.shared.insert(query: query, tableName: LevyDB.ExpenseListTableName) else{
            print("error: while inserting in \(LevyDB.FriendWiseExpenseTableName)")
            DBHelper.shared.closeDatabase()

             return nil
         }
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateTripWiseSum(for: expense.tripID, of: LevyDB.TripListTableColumn.TotalReturn, addition: expense.myTotalShare)
        DBHelper.shared.closeDatabase()
        
        return expID
    }
}

extension UseCase:SplitShareTableDBDelegate{
    func getSplitShareDetail(for expenseID: Int)->[SplitShare] {
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        let result = DBHelper.shared.readFromSplitShare(for: expenseID)
        DBHelper.shared.closeDatabase()
        
        return result
    }
    
    func insertIntoSplitShareTable(splitWith:SplitShare)->Bool{
        let query = "INSERT INTO \(LevyDB.SplitShareTableName) (\(LevyDB.SplitShareTableColumn.ExpenseID),\(LevyDB.SplitShareTableColumn.ShareWithFriendID),\(LevyDB.SplitShareTableColumn.ShareAmount)) VALUES (\(splitWith.expenseID ),\'\(splitWith.shareWithFriendID)\',\(splitWith.shareAmount));"
        //DBHelper.shared.closeDatabase()
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        guard DBHelper.shared.insert(query: query, tableName: LevyDB.SplitShareTableName) != nil else{
            print("error: while inserting in \(LevyDB.FriendsInTripTableName)")
            DBHelper.shared.closeDatabase()

             return false
         }
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateFriendsWiseExpTabel(for: splitWith.shareWithFriendID, addition: splitWith.shareAmount)
        DBHelper.shared.closeDatabase()

        return true
    }
    
    func updateSplitShare(expense:Expense,friendID:String,amount:Double)->Bool{
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        if DBHelper.shared.updateSplitShare(expID: expense.expenseID, friendID: friendID, amount: amount){}
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateMyShareInExpenseTable(expID: expense.expenseID)
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateTripWiseSum(for: expense.tripID, of: LevyDB.TripListTableColumn.TotalReturn, addition: amount)
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateFriendsWiseExpTabel(for: friendID, addition: amount)
        DBHelper.shared.closeDatabase()

        return true
    }
}

extension UseCase:FriendWiseExpDBDelegate{
    func getTripListFromDB(for friendID: String) -> [TripDetails] {
        let query  = """
    select \(LevyDB.TripListTableColumn.TripID),\(LevyDB.TripListTableColumn.TripName),\(LevyDB.TripListTableColumn.StartDate),\(LevyDB.TripListTableColumn.TotalReturn),\(LevyDB.TripListTableColumn.GroupID) from
        (select * from \(LevyDB.TripListTableName)
        left join \(LevyDB.FriendsInTripTableName)
        on \(LevyDB.TripListTableName).\(LevyDB.TripListTableColumn.TripID) = \(LevyDB.FriendsInTripTableName).\(LevyDB.FriendsInTripTableColumn.TripID)
        where \(LevyDB.FriendsInTripTableName).\(LevyDB.FriendsInTripTableColumn.FriendID) = \'\(friendID)\')
            ORDER BY \(LevyDB.TripListTableColumn.TotalReturn) = 0, \(LevyDB.TripListTableColumn.TotalReturn) DESC,\(LevyDB.TripListTableColumn.TripName);
"""
       
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        var result = DBHelper.shared.readFromTripListTable(queryExt: query,friendID: friendID)
        DBHelper.shared.closeDatabase()
        
        for trip in 0..<result.count{
            result[trip].startDate = formatDateFromMMtoMMM(dateAsString: result[trip].startDate)
        }
        return result
    }
}

extension UseCase:SettleUpFromFreindWiseExpDelegate{
    func settledFully(friendID: String) {
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.settledWholeAmount(friendID: friendID)
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateExpenseTableFromSplitShare()
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateTripTableFromExpense()
        DBHelper.shared.closeDatabase()
    }
    func settledPartialAmount(frindID:String,paidAmount:Double){
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.setteldPartialAmount(friendID: frindID, paid: paidAmount)
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateExpenseTableFromSplitShare()
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateTripTableFromExpense()
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateFriendsWiseExpTabel(for: frindID, addition: -paidAmount)
        DBHelper.shared.closeDatabase()
    }
    
}

extension UseCase:SettleUpFromFriendWiseDetailedDelegate{
    func settledUp(friendID: String, tripID: Int, amount: Double) {
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.settledTripWiseAmount(friendID: friendID, tripID: tripID, paid: amount)
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateExpenseTableFromSplitShare()
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateTripTableFromExpense()
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateFriendsWiseExpTabel(for: friendID, addition: -amount)
        DBHelper.shared.closeDatabase()

    }
}

extension UseCase:SelectedFriendWiseExpDelegate{
    func getFriendwiseExp(friendID: String) -> FriendWiseExpense? {
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        let condition = "WHERE \(LevyDB.FriendWiseExpenseTableColumn.FriendId) =\'\(friendID)\'"
        let result = DBHelper.shared.readFromFriendsWiseExpenseTable(condition: condition).first
        DBHelper.shared.closeDatabase()
        return result
    }
}

extension UseCase:SelectedTripDelegate{
    func getTripDetailFor(tripID: Int) -> TripDetails? {
        let condition = "WHERE \(LevyDB.TripListTableColumn.TripID) = \(tripID) ORDER BY \(LevyDB.TripListTableColumn.StartDate) DESC"
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        guard let resultFromDB = DBHelper.shared.readFromTripListTable(condition: condition).first else{
            print("***Error while unwrapping result @usecase.getTripDetailFor")
            DBHelper.shared.closeDatabase()
            return nil
        }
        DBHelper.shared.closeDatabase()
        
       var result = resultFromDB
        result.startDate = formatDateFromMMtoMMM(dateAsString: result.startDate)
        
        return result
    }
}

extension UseCase:GroupDBDelegate{
    func insertIntoGroupDetails(group: GroupDetails)->Int? {
        let query = "INSERT INTO \(LevyDB.GroupDetailsTableName) (\(LevyDB.GroupDetailsTableColumn.GroupName),\(LevyDB.GroupDetailsTableColumn.GroupDescription),\(LevyDB.GroupDetailsTableColumn.GroupImageURLString)) VALUES (\'\(group.groupName)\',\'\(group.groupDescription)\',\'\(group.groupImageURLString)\')"
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        let result = DBHelper.shared.insert(query: query, tableName: LevyDB.GroupDetailsTableName)
        DBHelper.shared.closeDatabase()
        
        return result
    }
    
    func insertIntoFriendsInGroup(friend: FriendsInGroup) {
        let query = "INSERT INTO \(LevyDB.FriendsInGroupTableName) (\(LevyDB.FriendsInGroupTableColumn.GroupID),\(LevyDB.FriendsInGroupTableColumn.FriendID)) VALUES (\(friend.groupID),\'\(friend.friendID)\')"
       
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        let _ = DBHelper.shared.insert(query: query, tableName: LevyDB.GroupDetailsTableName)
        DBHelper.shared.closeDatabase()
        
    }
    
    func getGroupDetailList()->[GroupDetails]{
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        let result = DBHelper.shared.readFromGroupDetailTable()
        DBHelper.shared.closeDatabase()
        
        return result
    }
}


extension UseCase:GroupDetailDBDelegate{
    
    func getTripDetailForGroup(groupID: Int) -> [TripDetails] {
        let condition = "WHERE \(LevyDB.TripListTableColumn.GroupID) = \(groupID) ORDER BY \(LevyDB.TripListTableColumn.StartDate) DESC,\(LevyDB.TripListTableColumn.TripName)"
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        var result = DBHelper.shared.readFromTripListTable(condition:condition)
        DBHelper.shared.closeDatabase()
        
        for trip in 0..<result.count{
            result[trip].startDate = formatDateFromMMtoMMM(dateAsString: result[trip].startDate)
        }
        
        return result
    }
    
    func getFriendsInGroup(for groupID: Int) -> [FriendsInGroup] {
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        let result = DBHelper.shared.readFromFriendsInGroupTable(groupID: groupID)
        DBHelper.shared.closeDatabase()
        
        return result
    }

}

extension UseCase:SelectedGroupDelegate{
    func getGroupDetail(for groupID: Int) -> GroupDetails? {
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        let condition = "WHERE \(LevyDB.FriendsInGroupTableColumn.GroupID) =\(groupID)"
        let result = DBHelper.shared.readFromGroupDetailTable(condition: condition).first
        DBHelper.shared.closeDatabase()
        return result
    }
}

extension UseCase:GroupWiseSumUpdationDelegate{
    func updateGroupWiseSum() {
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateExpenseTableFromSplitShare()
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateTripTableFromExpense()
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.updateGroupWiseShare()
        DBHelper.shared.closeDatabase()
    }
}


extension UseCase:GroupNameFromDBDelegate{
    func getGroupName(for ID: UInt) -> String? {
        let result = DBHelper.shared.getNameForGroupID(id: ID)
        return result
    }
}

extension UseCase:EntriesCountDelegate{
    func getEntriesCountInFriendsWiseExpTable() -> Int {
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        guard let result = DBHelper.shared.getNumberOfEntries(for: LevyDB.FriendWiseExpenseTableName) else{
            return 0
        }
        DBHelper.shared.closeDatabase()
        return result
    }
    func getEntriesCountInTripListTable()->Int{
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        guard let result = DBHelper.shared.getNumberOfEntries(for: LevyDB.TripListTableName) else{
            return 0
        }
        DBHelper.shared.closeDatabase()
        return result
    }
}
extension UseCase:AppSpcificContactDelegate{
    func readFromFriendWiseExpTable(existedID:[String]) -> [ContactDetail] {
        let condition = "WHERE \(LevyDB.FriendWiseExpenseTableColumn.FriendId) LIKE \'%Levy%\'"
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        let friends = DBHelper.shared.readFromFriendsWiseExpenseTable(condition: condition)
 
        DBHelper.shared.closeDatabase()
        var result = [ContactDetail]()
        for friend in friends{
            if existedID.contains(friend.friendID){
                continue
            }
            result.append(ContactDetail(identifier: friend.friendID, name: friend.name, telephone: friend.phoneNumber))
        }
        
        return result
    }
}

extension UseCase:SearchResultFromDBDelegate{
    func searchInFriendWiseTabel(for text: String,dataLimit:Int,dataOffset:Int) ->(Int, [FriendWiseExpense]) {
        let condition = "WHERE \(LevyDB.FriendWiseExpenseTableColumn.FriendName) LIKE \'%\(text)%\' OR \(LevyDB.FriendWiseExpenseTableColumn.PhoneNumber) LIKE \'%\(text)%\'  OR \(LevyDB.FriendWiseExpenseTableColumn.TotalReturn) LIKE \'%\(text)%\'"
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        let result = DBHelper.shared.readFromFriendsWiseExpenseTable(condition: condition,limit: dataLimit,offset: dataOffset)
        guard let totalEntries = DBHelper.shared.getNumberOfEntries(for: LevyDB.FriendWiseExpenseTableName,tableQueryCondition:  condition) else{
            return (0,result)
        }
        DBHelper.shared.closeDatabase()
        
        return (totalEntries,result)
    }
    
    func searchInTirpListTabel(for text: String, dataLimit: Int, dataOffset: Int) -> (Int,[TripDetails]) {
        let condition = "WHERE \(LevyDB.TripListTableColumn.TripName) LIKE \'%\(text)%\' OR \(LevyDB.TripListTableColumn.TotalReturn) LIKE \'%\(text)%\'  OR \(LevyDB.TripListTableColumn.StartDate) LIKE \'%\(text)%\'"
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        var result = DBHelper.shared.readFromTripListTable(limit: dataLimit, offset: dataOffset, condition: condition) //readFromFriendsWiseExpenseTable(condition: condition,limit: dataLimit,offset: dataOffset)
        for trip in 0..<result.count{
            result[trip].startDate = formatDateFromMMtoMMM(dateAsString: result[trip].startDate)
        }
        guard let totalEntries = DBHelper.shared.getNumberOfEntries(for: LevyDB.TripListTableName,tableQueryCondition:  condition) else{
            return (0,result)
        }
        DBHelper.shared.closeDatabase()
        
        
        return (totalEntries,result)
    }
}

extension UseCase:TotalReturnDelegate{
    func getTotalOwedAmount() -> Double {
        let condition = "where \(LevyDB.SplitShareTableColumn.ShareAmount) > 0"
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        let result = DBHelper.shared.getTotalReturn(condition: condition)
        DBHelper.shared.closeDatabase()
        
        return result
    }
    func getTotalOwingAmount() -> Double {
        let condition = "where \(LevyDB.SplitShareTableColumn.ShareAmount) < 0"
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        let result = DBHelper.shared.getTotalReturn(condition: condition)
        DBHelper.shared.closeDatabase()
        
        return result
    }
    
    func getTotalReturn() -> Double {
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        let result = DBHelper.shared.getTotalReturn()
        DBHelper.shared.closeDatabase()
        
        return result
    }
}
extension UseCase:NetworkHelperDelegate{
   
    func getImage(for url:String,searchText:String = "",cache:NSCache<AnyObject, AnyObject>? = nil,onCompletion:@escaping(UIImage?,LevyError?,String,Bool?)->Void) {
        
        NetworkHelper.willGetImageFromServer(for: url, cache: cache,searchText:searchText, onCompletion: {image,error,searchText,isFromCache in
            onCompletion(image,error,searchText,isFromCache)
        })
    }
}


extension UseCase:FetchImageAPIDelegate{
    func fetchImage(searchFor searchText: String, page: Int, totalPages:Int,totalResult:Int,previousResult:Int,onCompletion: @escaping(Error?, APIResponse?)->Void) {
        var searchText = searchText
        if searchText.isEmpty{
            searchText = "random"
        }
        let alterredSearchText = searchText.replacingOccurrences(of: " ", with: "+")
        
        let urlString = "https://api.unsplash.com/search/photos?query=\(alterredSearchText)&page=\(page)&per_page=20&client_id=hVM4qT_DkFnTShbWZBhjXBRtmNZh_z76cBdJklnGTc8"
        
        guard let url = URL(string: urlString)else{
            print("error while creating url")
            return
        }
        if page == 1{
            myURLSession?.invalidateAndCancel()
            myURLSession = nil
        }

        let urlSession = URLSession.shared
        urlSession.configuration.timeoutIntervalForRequest = 1
        urlSession.configuration.timeoutIntervalForResource = 3
        
        let task = urlSession.dataTask(with: url, completionHandler: { data,response,error in
            
            guard let data = data ,error == nil else {
                onCompletion(error,nil)
                return
            }
            do{
                let jsonResult = try JSONDecoder().decode(APIResponse.self, from: data)
                onCompletion(nil,jsonResult)
                return
            }catch{
                onCompletion(error,nil)
                print(error)
            }
        })
        if page <= totalPages && totalResult >= previousResult{
            task.resume()
        }
    }
}

extension UseCase:DeleteTripDelegate,DeleteExpenseDelegate,DeleteSplitDetailDelegate,DeleteFriendDetailDelegate{
    func deleteTrip(for tripid: Int) {
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.deleteExpense(in: tripid)
        DBHelper.shared.closeDatabase()
        
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.deleteTripDetails(for: tripid)
        DBHelper.shared.closeDatabase()
    }
    
    func deleteExpense(for expenseID: Int) {
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.deleteExpense(for:expenseID)
        DBHelper.shared.closeDatabase()
    }
    
    func deleteSplitDetail(for splitID: Int) {
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.deleteSplitDetails(for: splitID)
        DBHelper.shared.closeDatabase()
    }
    
    func deleteFriendDetail(for friendID: String) {
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.deleteFriendDetail(for: friendID)
        DBHelper.shared.closeDatabase()
    }
}

extension UseCase:FriendsDuesDelegate{
    func isFriendHaveDues(for friendID: String,in tripID:Int = 0,groupID:Int = 0) -> Bool {
        var query  = """
    select \(LevyDB.TripListTableColumn.TripID),\(LevyDB.TripListTableColumn.TripName),\(LevyDB.TripListTableColumn.StartDate),\(LevyDB.TripListTableColumn.TotalReturn),\(LevyDB.TripListTableColumn.GroupID) from
        (select * from \(LevyDB.TripListTableName)
        left join \(LevyDB.FriendsInTripTableName)
        on \(LevyDB.TripListTableName).\(LevyDB.TripListTableColumn.TripID) = \(LevyDB.FriendsInTripTableName).\(LevyDB.FriendsInTripTableColumn.TripID)
        where \(LevyDB.FriendsInTripTableName).\(LevyDB.FriendsInTripTableColumn.FriendID) = \'\(friendID)\')
            
"""
        if groupID != 0{
            query.append(contentsOf: " WHERE \(LevyDB.TripListTableColumn.GroupID) = \( groupID)")
        }else{
            query.append(contentsOf: " WHERE \(LevyDB.TripListTableColumn.TripID) = \(tripID)")
        }
       
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        let trips = DBHelper.shared.readFromTripListTable(queryExt: query,friendID: friendID)
        DBHelper.shared.closeDatabase()
        var result = false
        if groupID == 0{
            result = trips.first?.myShare == 0 ? false : true}
        else{
            for trip in trips {
                if trip.myShare != 0{
                    result = true
                    break
                }
            }
        }

        return result
    }
}
extension UseCase:DeleteFriendsFromGroupDelegate,DeleteFriendFromTripDelegate,DeleteGroupDelegate{
    func deleteFriendFromGroup(friendID: String, from groupID: Int) {
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.deleteFriendFromGroup(for: friendID,in:groupID)
        DBHelper.shared.closeDatabase()
    }
    
    func deleteFriendFromTrip(friendID: String, from tripID: Int) {
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.deleteFriendFromFriendsIntrip(for: friendID,in:tripID)
        DBHelper.shared.closeDatabase()
    }
    
    func deleteGroup(for groupID: Int) {
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        DBHelper.shared.deleteGroup(for: groupID)
        DBHelper.shared.closeDatabase()
    }
    
    
}

extension UseCase:FriendIDDelegate{
    func getFriendsID() -> [String] {
        DBHelper.shared.db = DBHelper.shared.openDataBase()
        let result = DBHelper.shared.getEntireFriendsID()
        DBHelper.shared.closeDatabase()
        guard let result = result else {
            return []
        }

        return result
    }
}
