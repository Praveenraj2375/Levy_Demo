//
//  DBHelper.swift
//  Levy
//
//  Created by Praveenraj T on 03/03/22.
//


import Foundation
import SQLite3
import UIKit



class DBHelper{
    static let shared = DBHelper()

    var db:OpaquePointer?
    var filePath :URL?
    let path = LevyDB.dbFile
    
    
    
    private init(){
        createDBFile()
        db = openDataBase()
        configureDB(db: db)
    }
    func configureDB(db:OpaquePointer?){
        print(path)
        var query  = """
            CREATE TABLE IF NOT EXISTS \(LevyDB.TripListTableName) (
                \(LevyDB.TripListTableColumn.TripID)        INTEGER PRIMARY KEY AUTOINCREMENT,
                \(LevyDB.TripListTableColumn.TripName)      TEXT    NOT NULL,
                \(LevyDB.TripListTableColumn.StartDate)     DATE    NOT NULL,
                \(LevyDB.TripListTableColumn.TotalReturn)   DOUBLE  NOT NULL DEFAULT (0),
                \(LevyDB.TripListTableColumn.GroupID)       INTEGER NOT NULL DEFAULT (0)
                                                            
                    );
        """
        createTable(tableName: LevyDB.TripListTableName, query: query)
        
        query = """
        
            CREATE TABLE IF NOT EXISTS \(LevyDB.FriendWiseExpenseTableName) (
            \(LevyDB.FriendWiseExpenseTableColumn.FriendId) STRING  PRIMARY KEY  NOT NULL,
            \(LevyDB.FriendWiseExpenseTableColumn.FriendName)  TEXT    NOT NULL,
            \(LevyDB.FriendWiseExpenseTableColumn.PhoneNumber) STRING  UNIQUE,
            \(LevyDB.FriendWiseExpenseTableColumn.TotalReturn) Double DEFAULT (0) NOT NULL
            );
        """
        createTable(tableName: LevyDB.FriendWiseExpenseTableName, query: query)
        
        query = """
            CREATE TABLE IF NOT EXISTS \(LevyDB.ExpenseListTableName) (
                \(LevyDB.ExpenseListTableColumn.ExpenseID)      INTEGER PRIMARY KEY AUTOINCREMENT,
                \(LevyDB.ExpenseListTableColumn.TripID)         INTEGER REFERENCES \(LevyDB.TripListTableName) NOT NULL,
        \(LevyDB.ExpenseListTableColumn.expenseDate)    DATE    NOT NULL,
                \(LevyDB.ExpenseListTableColumn.ExpenseName)    TEXT    NOT NULL,
                \(LevyDB.ExpenseListTableColumn.PaidByFriendID) STRING,
                \(LevyDB.ExpenseListTableColumn.TotalAmount)    Double DEFAULT (0),
                \(LevyDB.ExpenseListTableColumn.MyTotalShare )  Double DEFAULT (0)
            );
        """
        createTable(tableName: LevyDB.ExpenseListTableName, query: query)
        
        query = """
            CREATE TABLE IF NOT EXISTS \(LevyDB.SplitShareTableName) (
                \(LevyDB.SplitShareTableColumn.SplitID)           INTEGER PRIMARY KEY AUTOINCREMENT,
                \(LevyDB.SplitShareTableColumn.ExpenseID )        INTEGER REFERENCES \(LevyDB.ExpenseListTableName) ON DELETE CASCADE
                              NOT NULL,
                \(LevyDB.SplitShareTableColumn.ShareWithFriendID) STRING,
                \(LevyDB.SplitShareTableColumn.ShareAmount)       Double DEFAULT (0),
        
                    UNIQUE (
                        \(LevyDB.SplitShareTableColumn.ExpenseID),
                        \(LevyDB.SplitShareTableColumn.ShareWithFriendID)
                    )
            );
        """
        createTable(tableName: LevyDB.SplitShareTableName, query: query)
        
        query = """
            CREATE TABLE IF NOT EXISTS \(LevyDB.GroupDetailsTableName) (
              \(LevyDB.GroupDetailsTableColumn.GroupID)          INTEGER PRIMARY KEY AUTOINCREMENT,
              \(LevyDB.GroupDetailsTableColumn.GroupName)        TEXT    NOT NULL,
              \(LevyDB.GroupDetailsTableColumn.GroupDescription) TEXT,
              \(LevyDB.GroupDetailsTableColumn.GroupWiseShare )  Double DEFAULT (0)  NOT NULL,
            \(LevyDB.GroupDetailsTableColumn.GroupImageURLString) TEXT NOT NULL
            );
        
        """
        createTable(tableName: LevyDB.GroupDetailsTableName, query: query)
        
        
        query = """
        CREATE TABLE IF NOT EXISTS \(LevyDB.FriendsInGroupTableName) (
            \(LevyDB.FriendsInGroupTableColumn.FriendInGroupID) INTEGER PRIMARY KEY AUTOINCREMENT,
            \(LevyDB.FriendsInGroupTableColumn.GroupID)         INTEGER REFERENCES \(LevyDB.GroupDetailsTableName) ON DELETE CASCADE NOT NULL,
            \(LevyDB.FriendsInGroupTableColumn.FriendID)        STRING REFERENCES \(LevyDB.FriendWiseExpenseTableName) ON DELETE CASCADE NOT NULL,
            UNIQUE (
                \(LevyDB.FriendsInGroupTableColumn.GroupID),
                \(LevyDB.FriendsInGroupTableColumn.FriendID)
            )
        );
        """
        createTable(tableName: LevyDB.FriendsInGroupTableName, query: query)
        
        query = """
        CREATE TABLE IF NOT EXISTS \(LevyDB.FriendsInTripTableName) (
        \(LevyDB.FriendsInTripTableColumn.FriendIDInTripTableKey)   INTEGER PRIMARY KEY AUTOINCREMENT,
        \(LevyDB.FriendsInTripTableColumn.TripID)  INTEGER REFERENCES \(LevyDB.TripListTableName) ON DELETE CASCADE NOT NULL,
        \(LevyDB.FriendsInTripTableColumn.FriendID)    STRING REFERENCES \(LevyDB.FriendWiseExpenseTableName) ON DELETE CASCADE NOT NULL,
            UNIQUE (
                    \(LevyDB.FriendsInTripTableColumn.TripID) ,
                    \(LevyDB.FriendsInTripTableColumn.FriendID)
            )
        );
        
        """
        
        createTable(tableName: LevyDB.FriendsInTripTableName, query: query)
        
        closeDatabase()
    }
    
    
    func createDBFile(){
        do{ let formmedFilePath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(path)
            filePath = formmedFilePath
            guard let filePath = filePath else {
                return
            }
            
            print(filePath.path)
        }catch{
            print(error)
        }
        
    }
    
    func openDataBase()->OpaquePointer?{
        var db :OpaquePointer?
        guard let filePath = filePath else {
            return nil
        }
        if sqlite3_open(filePath.path, &db) != SQLITE_OK{
            print("Error: cannot open DB")
            return nil
        }
        else{
            print("DB opened successfully")
            return db
        }
    }
    
    func closeDatabase(){
        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }else{
            print("DB closed")}

    }
    
    func createTable(tableName:String,query:String){
        var createTable:OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &createTable, nil) == SQLITE_OK{
            if sqlite3_step(createTable) == SQLITE_DONE{
                print("\(tableName) creation successfull")
            }else{
                print("Error:step error")
            }
            
        }else{
            print("Error:while preparing \(tableName) ")
        }
        sqlite3_finalize(createTable)
    }
    
    func insert(query:String,tableName:String)->Int?{
        
        
        var errMsg : UnsafeMutablePointer<Int8>? = nil
        
        if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
            print("insertion updation failed Cannot execute query")
            if let errMsg = errMsg {
                print(String(cString: errMsg))
            }
            return nil

        }else{
            print("Insert into -\(tableName)")
            return Int(sqlite3_last_insert_rowid(db))
        }
        
    }
    
    
    func readFromTripListTable(limit:Int = 0,offset:Int = 0, queryExt:String = "",friendID:String = "",condition:String = "")->[TripDetails]{
        updateExpenseTableFromSplitShare(isInnerCalled: true)

        var tripList = [TripDetails]()
        var query = ""
        if queryExt == ""{
            query = "SELECT * FROM \(LevyDB.TripListTableName) "+condition
        }else{
            query = queryExt
        }

        if limit != 0{
            query.append(contentsOf: " LIMIT \(limit) OFFSET \(offset)")
        }
        
        var statement:OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            while sqlite3_step(statement) == SQLITE_ROW{
                var trip = TripDetails(
                    tripID: Int(sqlite3_column_int(statement, 0)),
                    tripName: String(cString: sqlite3_column_text(statement, 1)),
                    startDate: String(cString: sqlite3_column_text(statement, 2)),
                    myShare: Double(sqlite3_column_double(statement, 3)),
                    groupID: UInt(sqlite3_column_int(statement, 4)))
                
                trip.myShare = round(trip.myShare*100)/100
                trip.friendsCount = countFriends(in: LevyDB.FriendsInTripTableName, idname: LevyDB.FriendsInTripTableColumn.TripID, for: trip.tripID)
                trip.totalExpense = getTripWiseSum(for: trip.tripID, of: LevyDB.ExpenseListTableColumn.TotalAmount)
                trip.myShare = getTripWiseSum(for: trip.tripID, of: LevyDB.ExpenseListTableColumn.MyTotalShare)
                
                if queryExt != ""{
                    trip.totalExpense = trip.myShare
                    trip.myShare = getTripWiseFriendReturn(for: friendID, tripID: trip.tripID)
                }
                trip.myShare = round(trip.myShare*100)/100
                trip.totalExpense = round(trip.totalExpense*100)/100
                
                tripList.append(trip)
            }
            
        }else{
            print("read preparation failed..!readFromTripListTable")
            sqlite3_finalize(statement)
            
            return []
        }
        sqlite3_finalize(statement)
        
        return tripList
    }
    
    func getTripWiseFriendReturn(for friendID:String,tripID:Int)->Double{
        let db = openDataBase()
        let query = """
        select sum(\(LevyDB.SplitShareTableColumn.ShareAmount))
        from( select * from \(LevyDB.SplitShareTableName)
        left join \(LevyDB.ExpenseListTableName)
        on \(LevyDB.SplitShareTableName).\(LevyDB.SplitShareTableColumn.ExpenseID) = \(LevyDB.ExpenseListTableName).\(LevyDB.ExpenseListTableColumn.ExpenseID)
        
        where \(LevyDB.SplitShareTableName).\(LevyDB.SplitShareTableColumn.ShareWithFriendID) = \'\(friendID)\'
        and expenselist.TripID = \(tripID));
        """
        var statement:OpaquePointer?
        
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing select statement")
            sqlite3_finalize(statement)
            closeTempDatabase(db: db)
            return 0
        }
        
        guard sqlite3_step(statement) == SQLITE_ROW else {
            print("*** Error fetching items\n")//,sqlite3_errmsg(db))
            sqlite3_finalize(statement)
            closeTempDatabase(db: db)
            return 0
        }
    
        var result = Double(sqlite3_column_double(statement, 0))
        result = round(result*100)/100
        sqlite3_finalize(statement)
        
    

        return result
    }
    
    func countFriends(in tableName:String,idname:String,for id:Int)->UInt{
        let selfConnection = openDataBase()
        let query = "SELECT count() FROM (SELECT * FROM \(tableName) WHERE \(idname) = \(id))"
        var statement:OpaquePointer?
        
        guard sqlite3_prepare_v2(selfConnection, query, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing count statement \(tableName)")
            sqlite3_finalize(statement)
            closeTempDatabase(db: selfConnection)
            return 0
        }
        
        guard sqlite3_step(statement) == SQLITE_ROW else {
            print("*** Error fetching items\n")//,sqlite3_errmsg(db))
            sqlite3_finalize(statement)
            closeTempDatabase(db: selfConnection)
            return 0
        }
        
        let result =  UInt(sqlite3_column_int(statement, 0))
        sqlite3_finalize(statement)
        closeTempDatabase(db: selfConnection)
        return result
    }
    
    func getTripWiseSum(for tripID:Int,of column:String)->Double{
        let db = openDataBase()
        var totalShare = Double()
        let query = "SELECT SUM(\(column)) FROM \(LevyDB.ExpenseListTableName) WHERE \(LevyDB.ExpenseListTableColumn.TripID) = \(tripID)"
        var statement:OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            guard sqlite3_step(statement) == SQLITE_ROW else{
                sqlite3_finalize(statement)
                closeTempDatabase(db: db)
                return 0}
            
            totalShare = Double(sqlite3_column_double(statement, 0))
            totalShare = round(totalShare*100)/100
            
        }else{
            print("read preparation failed..!getTripWiseSum")
            sqlite3_finalize(statement)
            closeTempDatabase(db: db)
            return 0
        }
        sqlite3_finalize(statement)
        closeTempDatabase(db: db)

        return totalShare
        
    }
    
    func updateTripWiseSum(for tripID:Int,of column:String,addition:Double){
        
        var totalShare = Double()
        var query = "SELECT \(column) FROM \(LevyDB.TripListTableName) WHERE \(LevyDB.ExpenseListTableColumn.TripID) = \(tripID);"
        var statement:OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            guard sqlite3_step(statement) == SQLITE_ROW else{
                
                sqlite3_finalize(statement)
                
                return
                
            }
            
            totalShare = Double(sqlite3_column_double(statement, 0))
            sqlite3_finalize(statement)

            
        }else{
            print("read preparation failed..!updateTripWiseSum")
            sqlite3_finalize(statement)
            
            return
        }
        
        query = "UPDATE \(LevyDB.TripListTableName) SET \(column) = \(totalShare+addition) WHERE \(LevyDB.TripListTableName).\(LevyDB.TripListTableColumn.TripID) = \(tripID);"
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            guard sqlite3_step(statement) == SQLITE_DONE else{
                print(String.init(cString:  sqlite3_errmsg(db)!))
                sqlite3_finalize(statement)
                return
            }
            sqlite3_finalize(statement)
        }else{
            print("read preparation failed..!trip list table")
            sqlite3_finalize(statement)
            
            return
        }
    }
    
    func updateFriendsWiseExpTabel(for friendID:String,addition:Double){
        
        var totalShare = Double()
        var query = "SELECT \(LevyDB.FriendWiseExpenseTableColumn.TotalReturn) FROM \(LevyDB.FriendWiseExpenseTableName) WHERE \(LevyDB.FriendWiseExpenseTableColumn.FriendId) = \'\(friendID)\';"
        var statement:OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            guard sqlite3_step(statement) == SQLITE_ROW else{
                sqlite3_finalize(statement)
                return }
            
            totalShare = Double(sqlite3_column_double(statement, 0))
            sqlite3_finalize(statement)

        }else{
            print("read preparation failed..!updateFriendsWiseExpTabel")
            sqlite3_finalize(statement)
            return
        }

        query = "UPDATE \(LevyDB.FriendWiseExpenseTableName) SET \(LevyDB.FriendWiseExpenseTableColumn.TotalReturn) = \(totalShare+addition) WHERE \(LevyDB.FriendWiseExpenseTableColumn.FriendId) = \'\(friendID)\'"
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            guard sqlite3_step(statement) == SQLITE_DONE else{
                print("error")
                sqlite3_finalize(statement)
                
                return
                
            }
            sqlite3_finalize(statement)

        }else{
            print("read preparation failed..!updateFriendsWiseExpTabel")
            sqlite3_finalize(statement)
            
            return
        }
        
    }
    
    func updateMyShareInExpenseTable(expID:Int){
        
        var query = """
        SELECT SUM(\(LevyDB.SplitShareTableColumn.ShareAmount))
        FROM \(LevyDB.SplitShareTableName)
        WHERE \(LevyDB.SplitShareTableColumn.ExpenseID) = \(expID);
        """
        var statement:OpaquePointer?
        
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing expense update statement")
            sqlite3_finalize(statement)
            //closeDatabase()
            return
        }
        
        guard sqlite3_step(statement) == SQLITE_ROW else {
            print("*** Error fetching items\n")
            sqlite3_finalize(statement)
            return
        }
        

        let newShare = Double(sqlite3_column_int(statement, 0))
        sqlite3_finalize(statement)
        
        query = "UPDATE \(LevyDB.ExpenseListTableName) SET \(LevyDB.ExpenseListTableColumn.MyTotalShare) = \(newShare) WHERE \(LevyDB.ExpenseListTableColumn.ExpenseID) = \(expID);"
        
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing expense updation statement")
            sqlite3_finalize(statement)
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE{
            sqlite3_finalize(statement)
            
            return
        } else {
            print("*** Error fetching items\n")
            sqlite3_finalize(statement)
            return
        }

        
    }
    
    
    
    func readFromFriendsWiseExpenseTable(condition:String = "",limit:Int = 0, offset:Int = 0)->[FriendWiseExpense]{
        var friends = [FriendWiseExpense]()
        var query = "SELECT * FROM \(LevyDB.FriendWiseExpenseTableName) "+condition
        
        if condition == ""{
            query.append( " ORDER BY \(LevyDB.FriendWiseExpenseTableColumn.FriendName)")
        }

        if limit != 0{
            query.append(contentsOf: " LIMIT \(limit) OFFSET \(offset)")
        }
        
        

        var statement:OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            while sqlite3_step(statement) == SQLITE_ROW{
                
                var friend = FriendWiseExpense(
                    friendID    : String(cString: sqlite3_column_text(statement, 0)),
                    name        : String(cString: sqlite3_column_text(statement, 1)),
                    phoneNumber : String(cString: sqlite3_column_text(statement, 2)),
                    totalReturn : Double(sqlite3_column_double(statement, 3))
                )
                
                friend.totalReturn = round(friend.totalReturn*100)/100
                friends.append(friend)
            }

            
        }else{
            print("\(LevyDB.FriendWiseExpenseTableName) read preparation failed..!")
            sqlite3_finalize(statement)
            
            return []
        }
        
        sqlite3_finalize(statement)

        return friends
    }
    
    func readFromFriendsInTripTable(condition:String)->[FriendsInTrip]{
        var friends = [FriendsInTrip]()
        let query =  """
            SELECT \(LevyDB.FriendsInTripTableColumn.TripID),
            \(LevyDB.FriendsInTripTableColumn.FriendID),
            \(LevyDB.FriendWiseExpenseTableColumn.FriendName),
            \(LevyDB.FriendWiseExpenseTableColumn.PhoneNumber)
            
            FROM (select * from \(LevyDB.FriendWiseExpenseTableName)
                    left join \(LevyDB.FriendsInTripTableName)
                    on \(LevyDB.FriendWiseExpenseTableName).\(LevyDB.FriendWiseExpenseTableColumn.FriendId) = \(LevyDB.FriendsInTripTableName).\(LevyDB.FriendsInTripTableColumn.FriendID))
            
            """ + condition
        var statement:OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            while sqlite3_step(statement) == SQLITE_ROW{
                
                let friend = FriendsInTrip(
                    tripID: Int(sqlite3_column_int(statement, 0)),
                    friendID: String(cString: sqlite3_column_text(statement, 1)),
                    friendName: String(cString: sqlite3_column_text(statement, 2)),
                    friendPhoneNumber: String(cString: sqlite3_column_text(statement, 3)))
                friends.append(friend)
            }
            sqlite3_finalize(statement)

            
        }else{
            print("\(LevyDB.FriendsInTripTableName) read preparation failed..!")
            sqlite3_finalize(statement)
                        return []
        }
        
        return friends
        
    }
    
    func readFromExpenseTable(tripID:Int)->[Expense]{
        //db = opendatabase()
        var expenseList = [Expense]()
        let query =  """
            SELECT *
            FROM \(LevyDB.ExpenseListTableName)
            WHERE \(LevyDB.ExpenseListTableColumn.TripID) = \(tripID)
            ORDER BY \(LevyDB.ExpenseListTableColumn.expenseDate) DESC;
            
            """
        var statement:OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            while sqlite3_step(statement) == SQLITE_ROW{
                var expense = Expense(
                    expenseID: Int(sqlite3_column_int(statement, 0)),
                    tripID: Int(sqlite3_column_int(statement, 1)),
                    expenseName: String(cString: sqlite3_column_text(statement, 3)),
                    paidByFriendID: String(cString: sqlite3_column_text(statement, 4)),
                    paidByFriendName: " ",
                    totalAmount: Double(sqlite3_column_double(statement, 5)),
                    myTotalShare: Double(sqlite3_column_double(statement, 6)),
                    expenseDate: String(cString: sqlite3_column_text(statement, 2)))
                
                
                if expense.paidByFriendID == "0"{
                    expense.paidByFriendName = "Me "
                }
                else{
                    guard let name = getNameForFriendID(id: expense.paidByFriendID) else{
                        print("***Error : while getting name from DB")
                        sqlite3_finalize(statement)
                        
                        return []
                    }
                    expense.paidByFriendName = name
                }
                expense.myTotalShare = round(expense.myTotalShare*100)/100
                expense.totalAmount = round(expense.totalAmount*100)/100
                expenseList.append(expense)
            }
            
        }else{
            print("expense table read preparation failed..!")
            sqlite3_finalize(statement)
            
            return []
        }
        sqlite3_finalize(statement)
        
        return expenseList
    }
    
    func readFromSplitShare(for expenseID:Int)->[SplitShare]{
        
        var splitShare = [SplitShare]()
        let query =  """
            SELECT *
            FROM \(LevyDB.SplitShareTableName)
            WHERE \(LevyDB.SplitShareTableColumn.ExpenseID) = \(expenseID)
            ORDER BY \(LevyDB.SplitShareTableColumn.ShareAmount) = 0,\(LevyDB.SplitShareTableColumn.ShareAmount) ;
            """
        var statement:OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            while sqlite3_step(statement) == SQLITE_ROW{
                var split = SplitShare(
                    splitID:Int(sqlite3_column_int(statement, 0)),
                    expenseID: expenseID,
                    shareWithFriendID: String(cString: sqlite3_column_text(statement, 2)),
                    friendName: " ",
                    shareAmount: Double(sqlite3_column_double(statement, 3)))
                
                
                guard let name = getNameForFriendID(id: split.shareWithFriendID) else{
                    print("***Error : while getting name from DB")
                    sqlite3_finalize(statement)
                    
                    return []
                }
                split.friendName = name
                split.shareAmount = round(split.shareAmount*100)/100
                splitShare.append(split)
            }
            
        }else{
            print("\(LevyDB.SplitShareTableName) read preparation failed..!")
            sqlite3_finalize(statement)
            
            return []
        }
        splitShare = splitShare.sorted(by: {$0.friendName < $1.friendName})
        sqlite3_finalize(statement)
        return splitShare
    }
    
    func updateSplitShare(expID:Int,friendID:String,amount:Double)->Bool{
        
        var totalShare = Double()
        var query = "SELECT \(LevyDB.SplitShareTableColumn.ShareAmount) FROM \(LevyDB.SplitShareTableName) WHERE \(LevyDB.SplitShareTableColumn.ExpenseID) = \(expID) AND \(LevyDB.SplitShareTableColumn.ShareWithFriendID) = \'\(friendID)\';"
        var statement:OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            guard sqlite3_step(statement) == SQLITE_ROW else{
                sqlite3_finalize(statement)
                return false
            }
            totalShare = Double(sqlite3_column_double(statement, 0))
            sqlite3_finalize(statement)
        }
        else{
            print("read preparation failed..!updateSplitShare")
            sqlite3_finalize(statement)
            return false
        }

        query = "UPDATE \(LevyDB.SplitShareTableName) SET \(LevyDB.SplitShareTableColumn.ShareAmount) = \(totalShare+amount) WHERE \(LevyDB.SplitShareTableColumn.ExpenseID) = \(expID) AND \(LevyDB.SplitShareTableColumn.ShareWithFriendID) = \'\(friendID)\';"
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            if sqlite3_step(statement) == SQLITE_OK {
                sqlite3_finalize(statement)
                return true
            }
            else{
                sqlite3_finalize(statement)
                return false
            }
        }else{
            print("read preparation failed..!updateSplitShare")
            sqlite3_finalize(statement)
            return false
        }
    }
    
    func getNameForFriendID(id:String)->String?{
        let db = openDataBase()
        let query = "SELECT \(LevyDB.FriendWiseExpenseTableColumn.FriendName) FROM \(LevyDB.FriendWiseExpenseTableName) WHERE \(LevyDB.FriendWiseExpenseTableColumn.FriendId) = \'\(id)\';"
        var statement:OpaquePointer?
        var name = String()
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW{
                name = String(cString:sqlite3_column_text(statement, 0))
            }
            sqlite3_finalize(statement)
        }else{
            print("get friendName read preparation failed..!")
            sqlite3_finalize(statement)
            closeTempDatabase(db: db)
            return nil
        }
        closeTempDatabase(db: db)
        return name
    }
    
    func getNameForGroupID(id: UInt)->String?{
        let db = openDataBase()
        let query = "SELECT \(LevyDB.GroupDetailsTableColumn.GroupName) FROM \(LevyDB.GroupDetailsTableName) WHERE \(LevyDB.GroupDetailsTableColumn.GroupID) = \(id);"
        var statement:OpaquePointer?
        var name = String()
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW{
                name = String(cString:sqlite3_column_text(statement, 0))
            }
            sqlite3_finalize(statement)
        }else{
            print("get groupName read preparation failed..!")
            sqlite3_finalize(statement)
            closeTempDatabase(db: db)
            return nil
        }
        closeTempDatabase(db: db)
        if name == ""{
            return nil
        }
        return name

    }
    
    func getPhoneNumberForFriendId(id:String)->String?{
        let db = openDataBase()
        let query = "SELECT \(LevyDB.FriendWiseExpenseTableColumn.PhoneNumber) FROM \(LevyDB.FriendWiseExpenseTableName) WHERE \(LevyDB.FriendWiseExpenseTableColumn.FriendId) = \'\(id)\';"
        var statement:OpaquePointer?
        var phoneNumber = String()
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            guard sqlite3_step(statement) == SQLITE_ROW else{
                print("*** Error- Fetching details @ getPhoneNumberForFriendId")
                sqlite3_finalize(statement)
                closeTempDatabase(db: db)
                return nil
            }
            phoneNumber = String(cString:sqlite3_column_text(statement, 0))
            sqlite3_finalize(statement)

            
        }else{
            print("get Phonenumber read preparation failed..!")
            sqlite3_finalize(statement)
            closeTempDatabase(db: db)
            return nil
        }
        closeTempDatabase(db: db)
        return phoneNumber
    }
}

extension DBHelper{
    func settledWholeAmount(friendID:String){
        var query = """
        UPDATE \(LevyDB.SplitShareTableName)
        SET \(LevyDB.SplitShareTableColumn.ShareAmount) = 0
        WHERE \(LevyDB.SplitShareTableColumn.ShareWithFriendID) = \'\(friendID)\';
    
    """

        var errMsg : UnsafeMutablePointer<Int8>? = nil
        
        if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
            print("split share updation failed Cannot execute query")
            if let errMsg = errMsg {
                print(String(cString: errMsg))
            }
        }else{
            print("split share updation ok")
        }
        
        query = """
        UPDATE \(LevyDB.FriendWiseExpenseTableName)
        SET \(LevyDB.FriendWiseExpenseTableColumn.TotalReturn) = 0
        WHERE \(LevyDB.FriendWiseExpenseTableColumn.FriendId) = \'\(friendID)\';
    """
        if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
            print("friend wise updation failed Cannot execute query")
            if let errMsg = errMsg {
                print(String(cString: errMsg))
            }
        }else{
            print("friend wise updation ok")
        }
    }
    
    func setteldPartialAmount(friendID:String,paid:Double){
        struct UpdatedValue{
            var splitID:Int
            var shareAmount:Double
        }
        var paidAmount = paid
        var arrayOfUpdatedShare = [UpdatedValue]()
        var condition = " "
        var query = """
        select * from \(LevyDB.SplitShareTableName)
        where \(LevyDB.SplitShareTableColumn.ShareWithFriendID) = \'\(friendID)\'
        
        """
        if paidAmount > 0{
            condition = " AND \(LevyDB.SplitShareTableColumn.ShareAmount) > 0 "
        }
        else{
            condition = " AND \(LevyDB.SplitShareTableColumn.ShareAmount) < 0 "
        }
        query.append(condition)
        
        var statement : OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            while sqlite3_step(statement) == SQLITE_ROW{
                
                let valueFromDB = UpdatedValue(
                    splitID: Int(sqlite3_column_int(statement, 0)),
                    shareAmount: Double(sqlite3_column_double(statement, 3)))
                arrayOfUpdatedShare.append(valueFromDB)
                
            }
            sqlite3_finalize(statement)
        }else{
            print("***Error while preparing DB statement :@setteldPartialAmount")
            sqlite3_finalize(statement)
        }
        var index = 0
        
        while paidAmount.magnitude > 0 && arrayOfUpdatedShare.count > index{
            if arrayOfUpdatedShare[index].shareAmount.magnitude >= paidAmount.magnitude{
                arrayOfUpdatedShare[index].shareAmount -= paidAmount
                arrayOfUpdatedShare[index].shareAmount = round(arrayOfUpdatedShare[index].shareAmount*100)/100
                paidAmount = 0
            }
            else{
                paidAmount -= arrayOfUpdatedShare[index].shareAmount
                arrayOfUpdatedShare[index].shareAmount = 0
                
            }
            index += 1
            
        }
        index -= 1
        if paidAmount > 0 && index == arrayOfUpdatedShare.count-1 && index>=0{
            
            arrayOfUpdatedShare[index].shareAmount += paidAmount
        }
        
        for newShare in arrayOfUpdatedShare{
            query = """
                UPDATE \(LevyDB.SplitShareTableName)
                SET \(LevyDB.SplitShareTableColumn.ShareAmount) = \(newShare.shareAmount)
                WHERE \(LevyDB.SplitShareTableColumn.SplitID) = \(newShare.splitID)
            """
            var errMsg : UnsafeMutablePointer<Int8>? = nil

            if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
                print("Cannot execute query settle uptaion  failed")
                if let errMsg = errMsg {
                    print(String(cString: errMsg))
                }
            }else{
                print("expense updation ok")
            }
            
        }
    }
    
    func updateExpenseTableFromSplitShare(isInnerCalled:Bool = false){
        var myDB:OpaquePointer?
        if isInnerCalled{
            myDB = openDataBase()
        }
        let query = """
        drop table if exists temp.result;
       
         create temporary table result as
         select \(LevyDB.SplitShareTableColumn.ExpenseID) as expid,sum(\(LevyDB.SplitShareTableColumn.ShareAmount)) as cost
         from \(LevyDB.SplitShareTableName)
         group by \(LevyDB.SplitShareTableColumn.ExpenseID);
         
        
        UPDATE \(LevyDB.ExpenseListTableName)
        SET \(LevyDB.ExpenseListTableColumn.MyTotalShare) = (SELECT temp.result.cost
            FROM temp.result
            WHERE temp.result.expid = \(LevyDB.ExpenseListTableName).\(LevyDB.ExpenseListTableColumn.ExpenseID) )
       
        WHERE EXISTS (SELECT *
        FROM temp.result
        WHERE temp.result.expid = \(LevyDB.ExpenseListTableName).\(LevyDB.ExpenseListTableColumn.ExpenseID)
            );
        drop table temp.result;
       """
        
      
        var errMsg : UnsafeMutablePointer<Int8>? = nil
        
        if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
            print("Cannot execute query expense uptaion from splishare  failed")
            if let errMsg = errMsg {
                print(String(cString: errMsg))
            }
        }else{
            print("expense updation ok")
        }
        if isInnerCalled{
            closeTempDatabase(db: myDB)
        }
    }
    
    func updateTripTableFromExpense(){
        //db = opendatabase()
        let query = """
        drop table if exists temp.result;
    
        create temporary table result as
        select \(LevyDB.ExpenseListTableColumn.TripID) as trip , sum(\(LevyDB.ExpenseListTableColumn.MyTotalShare)) as cost
        from \(LevyDB.ExpenseListTableName)
        group by \(LevyDB.ExpenseListTableColumn.TripID);

        UPDATE \(LevyDB.TripListTableName)
            SET
                  \(LevyDB.TripListTableColumn.TotalReturn) =
        (SELECT temp.result.cost
            FROM temp.result
        WHERE temp.result.trip = \(LevyDB.TripListTableName).\(LevyDB.TripListTableColumn.TripID) )
        WHERE EXISTS (
            SELECT *
            FROM temp.result
            WHERE temp.result.trip = \(LevyDB.TripListTableName).\(LevyDB.TripListTableColumn.TripID));
            drop table temp.result;

"""
        
        var errMsg : UnsafeMutablePointer<Int8>? = nil
        
        if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
            print("Cannot execute query trip updation failed")
            if let errMsg = errMsg {
                print(String(cString: errMsg))
            }
        }else{
            print("trip updation ok")
        }
      
    }
    
    func settledTripWiseAmount(friendID:String,tripID:Int,paid:Double){
        
        struct UpdatedValue{
            var splitID:Int
            var shareAmount:Double
        }
        var paidAmount = paid
        var arrayOfUpdatedShare = [UpdatedValue]()
        var condition = " "
        var query = """
        select \(LevyDB.SplitShareTableColumn.SplitID),\(LevyDB.SplitShareTableColumn.ShareAmount) from \(LevyDB.SplitShareTableName)
        inner join \(LevyDB.ExpenseListTableName)
        on \(LevyDB.SplitShareTableName).\(LevyDB.ExpenseListTableColumn.ExpenseID) = \(LevyDB.ExpenseListTableName).\(LevyDB.ExpenseListTableColumn.ExpenseID)
        where \(LevyDB.ExpenseListTableName).\(LevyDB.ExpenseListTableColumn.TripID) = \(tripID)
        AND \(LevyDB.SplitShareTableColumn.ShareWithFriendID) = \'\(friendID)\'
        
        """
        if paidAmount > 0{
            condition = " AND \(LevyDB.SplitShareTableName).\(LevyDB.SplitShareTableColumn.ShareAmount) > 0 "
        }
        else{
            condition = " AND \(LevyDB.SplitShareTableName).\(LevyDB.SplitShareTableColumn.ShareAmount) < 0"
        }
        query.append(condition)
        
        var statement : OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW{
                let valueFromDB = UpdatedValue(
                    splitID: Int(sqlite3_column_int(statement, 0)),
                    shareAmount: Double(sqlite3_column_double(statement, 1)))
                arrayOfUpdatedShare.append(valueFromDB)
            }
            sqlite3_finalize(statement)
        }else{
            print("***Error while preparing DB statement :@setteldPartialAmount")
            sqlite3_finalize(statement)
        }
        var index = 0
        
        while paidAmount.magnitude > 0 && arrayOfUpdatedShare.count > index{
            if arrayOfUpdatedShare[index].shareAmount.magnitude >= paidAmount.magnitude{
                arrayOfUpdatedShare[index].shareAmount -= paidAmount
                arrayOfUpdatedShare[index].shareAmount = round(arrayOfUpdatedShare[index].shareAmount*100)/100
                paidAmount = 0
            }
            else{
                paidAmount -= arrayOfUpdatedShare[index].shareAmount
                arrayOfUpdatedShare[index].shareAmount = 0
            }
            index += 1
        }
        
        if paidAmount > 0{
            index -= 1
            arrayOfUpdatedShare[index].shareAmount -= paidAmount
        }
    
        for newShare in arrayOfUpdatedShare{
            query = """
                UPDATE \(LevyDB.SplitShareTableName)
                SET \(LevyDB.SplitShareTableColumn.ShareAmount) = \(newShare.shareAmount)
                WHERE \(LevyDB.SplitShareTableColumn.SplitID) = \(newShare.splitID)
            """
            var errMsg : UnsafeMutablePointer<Int8>? = nil

            if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
                print("Cannot execute query  trip wise expense uptaion  failed")
                if let errMsg = errMsg {
                    print(String(cString: errMsg))
                }
            }else{
                print("expense updation ok")
            }
        }
    }
    
    func updateGroupWiseShare(){
        let query = """

            drop table if exists temp.result;

              create temporary table result as
              select \(LevyDB.TripListTableColumn.GroupID) as id,sum(\(LevyDB.TripListTableColumn.TotalReturn)) as cost
              from \(LevyDB.TripListTableName)
              group by \(LevyDB.TripListTableColumn.GroupID);
              
            update \(LevyDB.GroupDetailsTableName)
            set \(LevyDB.GroupDetailsTableColumn.GroupWiseShare) = (SELECT temp.result.cost
                 FROM temp.result
                 WHERE temp.result.id = \(LevyDB.GroupDetailsTableName).\(LevyDB.GroupDetailsTableColumn.GroupID) )

             WHERE EXISTS (
                SELECT *
                FROM temp.result
                WHERE temp.result.id = \(LevyDB.GroupDetailsTableName).\(LevyDB.GroupDetailsTableColumn.GroupID)
                 );
             drop table temp.result;
        """
        
        var errMsg : UnsafeMutablePointer<Int8>? = nil
        
        if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
            print("Cannot execute query group wise share uptaion  failed")
            if let errMsg = errMsg {
                print(String(cString: errMsg))
            }
        }else{
            print("expense updation ok")
        }
    }
    
    func updateFriendWiseShare(){
        let query = """

            drop table if exists temp.result;

              create temporary table result as
              select \(LevyDB.SplitShareTableColumn.ShareWithFriendID) as id,sum(\(LevyDB.SplitShareTableColumn.ShareAmount)) as cost
              from \(LevyDB.SplitShareTableName)
              group by \(LevyDB.SplitShareTableColumn.ShareWithFriendID);
              
            update \(LevyDB.FriendWiseExpenseTableName)
            set \(LevyDB.FriendWiseExpenseTableColumn.TotalReturn) = (SELECT temp.result.cost
                 FROM temp.result
                 WHERE temp.result.id = \(LevyDB.FriendWiseExpenseTableName).\(LevyDB.FriendWiseExpenseTableColumn.FriendId) )

             WHERE EXISTS (
                SELECT *
                FROM temp.result
                WHERE temp.result.id = \(LevyDB.FriendWiseExpenseTableName).\(LevyDB.FriendWiseExpenseTableColumn.FriendId)
                 );
             drop table temp.result;
        """
        
        var errMsg : UnsafeMutablePointer<Int8>? = nil
        
        if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
            print("Cannot execute query expense uptaion  failed")
            if let errMsg = errMsg {
                print(String(cString: errMsg))
            }
        }else{
            print("Friends share updation ok")
        }
    }
}

extension DBHelper{
   func  closeTempDatabase(db:OpaquePointer?){
        if sqlite3_close(db) == SQLITE_OK{
            print("db Close- temp DB")
        }
        else{
            print("error closing DB")
        }
    }
}

extension DBHelper{
    func readFromGroupDetailTable(condition:String = "")->[GroupDetails]{
        updateGroupWiseShare()
        let query = "SELECT * FROM \(LevyDB.GroupDetailsTableName) " + condition + " ORDER BY \(LevyDB.GroupDetailsTableColumn.GroupName),\(LevyDB.GroupDetailsTableColumn.GroupWiseShare)"
        var groupDetail = [GroupDetails]()
        var statement:OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            while sqlite3_step(statement) == SQLITE_ROW{
                var group = GroupDetails(
                    groupID: Int(sqlite3_column_int(statement, 0)),
                    groupName: String(cString: sqlite3_column_text(statement, 1)),
                    groupDescription: String(cString: sqlite3_column_text(statement, 2)),
                    amount: Double(sqlite3_column_double(statement, 3)),
                groupImageURLString: String(cString: sqlite3_column_text(statement, 4)))
                group.friendsCountInGroup = Int(countFriends(in: LevyDB.FriendsInGroupTableName, idname: LevyDB.FriendsInGroupTableColumn.GroupID, for: group.groupID))
                groupDetail.append(group)
            }
            
        }else{
            print("read preparation failed..!readFromTripListTable")
            sqlite3_finalize(statement)
            
            return []
        }
        sqlite3_finalize(statement)
        
        return groupDetail
    }
    
    func readFromFriendsInGroupTable(groupID:Int)->[FriendsInGroup]{
        let query = "SELECT * FROM \(LevyDB.FriendsInGroupTableName) WHERE \(LevyDB.FriendsInGroupTableColumn.GroupID) = \(groupID)"
        var friendInGroupDetail = [FriendsInGroup]()
        var statement:OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            while sqlite3_step(statement) == SQLITE_ROW{
                var friend = FriendsInGroup(
                    groupID: Int(sqlite3_column_int(statement, 1)),
                    friendID:  String(cString: sqlite3_column_text(statement, 2)),
                    friendName: " ",
                    friendPhoneNumber: " ")

                guard let name = getNameForFriendID(id: friend.friendID)else {
                    print("***Error while unwrapping name")
                    return []
                }
                if let phone = getPhoneNumberForFriendId(id: friend.friendID){
                    friend.friendPhoneNumber = phone

                } else{
                    print("***Error while unwrapping phone number")
                    friend.friendPhoneNumber = " "


                }
                friend.friendName = name
                friendInGroupDetail.append(friend)
                
            }
            
        }else{
            print("read preparation failed..!readFromTripListTable")
            sqlite3_finalize(statement)
            
            return []
        }
        sqlite3_finalize(statement)
        friendInGroupDetail.sort(by: {$0.friendName < $1.friendName})
        return friendInGroupDetail
    }
}

extension DBHelper{
    func getNumberOfEntries(for tableName:String, tableQueryCondition:String = "")->Int?{
        var query =  "SELECT COUNT(*) FROM \'\(tableName)\' "
        if tableQueryCondition != ""{
            query.append(tableQueryCondition)
        }else{
           
        }
        
        var statement:OpaquePointer?
        var count = Int()
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            while sqlite3_step(statement) == SQLITE_ROW{
                count =  Int(sqlite3_column_int(statement, 0))// String(cString:sqlite3_column_text(statement, 0))
            }
            sqlite3_finalize(statement)

        }else{
            print("\(tableName) count read preparation failed..!")
            sqlite3_finalize(statement)
            //closeTempDatabase(db: db)
            return nil
        }

        return count
    }
    
    func getTotalReturn(condition:String="")->Double{
        //db = opendatabase()
        let db = openDataBase()
        var query = """
        select sum(\(LevyDB.SplitShareTableColumn.ShareAmount))
        from \(LevyDB.SplitShareTableName) 
        """
        if condition != ""{
            query.append(contentsOf: condition)
        }
        var statement:OpaquePointer?
        var totalShare = Double(0)
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            guard sqlite3_step(statement) == SQLITE_ROW else{
                sqlite3_finalize(statement)
                closeTempDatabase(db: db)
                return 0}
            
            totalShare = Double(sqlite3_column_double(statement, 0))
            totalShare = round(totalShare*100)/100
            
        }else{
            print("read preparation failed..!getTripWiseSum")
            sqlite3_finalize(statement)
            closeTempDatabase(db: db)
            return 0
        }
        sqlite3_finalize(statement)
        closeTempDatabase(db: db)

        return totalShare
    }
}

extension DBHelper{
    func readFromTripListTable(connection:OpaquePointer? = nil,limit:Int = 0,offset:Int = 0, queryExt:String = "",friendID:String = "",condition:String = "",onCompletion:(TripDetails)->Void){
        var db :OpaquePointer?
        
        if self.db == nil{
            db = connection
        }else{
            db = self.db
        }
        
        updateExpenseTableFromSplitShare(isInnerCalled: true)

        var tripList = [TripDetails]()
        var query = ""
        if queryExt == ""{
            query = "SELECT * FROM \(LevyDB.TripListTableName) "+condition
        }else{
            query = queryExt
        }
        if limit != 0{
            query.append(contentsOf: " LIMIT \(limit) OFFSET \(offset)")
        }
        
        var statement:OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            
            while sqlite3_step(statement) == SQLITE_ROW{
                
                var trip = TripDetails(
                    tripID: Int(sqlite3_column_int(statement, 0)),
                    tripName: String(cString: sqlite3_column_text(statement, 1)),
                    startDate: String(cString: sqlite3_column_text(statement, 2)),
                    myShare: Double(sqlite3_column_double(statement, 3)),
                    groupID: UInt(sqlite3_column_int(statement, 4)))
                
                trip.myShare = round(trip.myShare*100)/100
                trip.friendsCount = countFriends(in: LevyDB.FriendsInTripTableName, idname: LevyDB.FriendsInTripTableColumn.TripID, for: trip.tripID)
                trip.totalExpense = getTripWiseSum(for: trip.tripID, of: LevyDB.ExpenseListTableColumn.TotalAmount)
                trip.myShare = getTripWiseSum(for: trip.tripID, of: LevyDB.ExpenseListTableColumn.MyTotalShare)
                
                if queryExt != ""{
                    trip.totalExpense = trip.myShare
                    trip.myShare = getTripWiseFriendReturn(for: friendID, tripID: trip.tripID)
                }
                trip.myShare = round(trip.myShare*100)/100
                trip.totalExpense = round(trip.totalExpense*100)/100
                onCompletion(trip)
                tripList.append(trip)
            }
            
        }else{
            print("read preparation failed..!readFromTripListTable")
            sqlite3_finalize(statement)
            
            return 
        }
        sqlite3_finalize(statement)
        
        return
    }
    
}

extension DBHelper{
    func deleteExpense(in tripID:Int = 0,for expenseID:Int = 0){
        var query = """
        delete from \(LevyDB.ExpenseListTableName)
        """
        if tripID != 0{
            query.append(contentsOf: " where \(LevyDB.ExpenseListTableColumn.TripID) = \(tripID)")
        }
        if expenseID != 0{
            query.append(contentsOf: " where \(LevyDB.ExpenseListTableColumn.ExpenseID) = \(expenseID)")
        }
        
        var errMsg : UnsafeMutablePointer<Int8>? = nil
        
        if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
            print("Cannot execute query expense deletion  failed")
            if let errMsg = errMsg {
                print(String(cString: errMsg))
            }
        }else{
            print("expense deletion ok")
        }
    }

    func deleteTripDetails(for tripID:Int){
        let query = """
        delete from \(LevyDB.TripListTableName)
        where \(LevyDB.TripListTableColumn.TripID) = \(tripID)
        """
        
        var errMsg : UnsafeMutablePointer<Int8>? = nil
        
        if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
            print("Cannot execute query expense deletion  failed")
            if let errMsg = errMsg {
                print(String(cString: errMsg))
            }
        }else{
            print("expense deletion ok")
        }
    }
    
    func deleteSplitDetails(for splitID:Int){
        let query = """
        delete from \(LevyDB.SplitShareTableName)
        where \(LevyDB.SplitShareTableColumn.SplitID) = \(splitID)
        """
        
        var errMsg : UnsafeMutablePointer<Int8>? = nil
        
        if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
            print("Cannot execute query split deletion  failed")
            if let errMsg = errMsg {
                print(String(cString: errMsg))
            }
        }else{
            print("split deletion ok")
        }
    }
    
    func deleteFriendDetail(for friendID:String){
        let query = """
        delete from \(LevyDB.FriendWiseExpenseTableName)
        where \(LevyDB.FriendWiseExpenseTableColumn.FriendId) = \'\(friendID)\'
        """
        
        var errMsg : UnsafeMutablePointer<Int8>? = nil
        
        if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
            print("Cannot execute query friends detail deletion  failed")
            if let errMsg = errMsg {
                print(String(cString: errMsg))
            }
        }else{
            print("friends detail deletion ok")
        }
        deleteFriendFromFriendsIntrip(for: friendID)
        deleteFriendFromGroup(for: friendID)
    }
    
    func deleteFriendFromFriendsIntrip(for friendID:String,in tripID:Int = 0,groupID:Int = 0){
        var query = """
        delete from \(LevyDB.FriendsInTripTableName)
        where \(LevyDB.FriendsInTripTableColumn.FriendID) = \'\(friendID)\'
        """
        if tripID != 0{
            query.append(contentsOf: " and \(LevyDB.FriendsInTripTableColumn.TripID) = \(tripID)" )
        }
        
        var errMsg : UnsafeMutablePointer<Int8>? = nil
        
        if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
            print("Cannot execute query friends detail deletion  failed")
            if let errMsg = errMsg {
                print(String(cString: errMsg))
            }
        }else{
            print("friends detail deletion in trip ok")
        }
    }
    
    func deleteFriendFromGroup(for friendID:String,in groupID:Int = 0){
        var query = """
        delete from \(LevyDB.FriendsInGroupTableName)
        where \(LevyDB.FriendsInGroupTableColumn.FriendID) = \'\(friendID)\'
        """
        if groupID != 0{
            query.append(contentsOf: "and \(LevyDB.FriendsInGroupTableColumn.GroupID) = \(groupID)" )
        }
        var errMsg : UnsafeMutablePointer<Int8>? = nil
        
        if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
            print("Cannot execute query friends detail deletion in group  failed")
            if let errMsg = errMsg {
                print(String(cString: errMsg))
            }
        }else{
            print("friends detail deletion in group ok")
        }
    }
    
    func deleteGroup(for groupID:Int){
        let query = """
        delete from \(LevyDB.GroupDetailsTableName)
        where \(LevyDB.GroupDetailsTableColumn.GroupID) = \(groupID)
        """
        
        var errMsg : UnsafeMutablePointer<Int8>? = nil
        
        if sqlite3_exec(db, query, nil, nil, &errMsg) != SQLITE_OK {
            print("Cannot execute query group deletion in group  failed")
            if let errMsg = errMsg {
                print(String(cString: errMsg))
            }
        }else{
            print("group deletion in group ok")
        }
    }
}


extension DBHelper{
    func getEntireFriendsID()->[String]?{
        let query = "SELECT \(LevyDB.FriendsInTripTableColumn.FriendID) FROM \(LevyDB.FriendWiseExpenseTableName) ;"
        var statement:OpaquePointer?
        var name = [String]()
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW{
                name.append(String(cString:sqlite3_column_text(statement, 0)))
            }
            sqlite3_finalize(statement)
        }else{
            print("get groupName read preparation failed..!")
            sqlite3_finalize(statement)
            return nil
        }
        return name
    }
}
