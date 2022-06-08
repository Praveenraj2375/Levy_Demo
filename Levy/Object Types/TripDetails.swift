//
//  TripDetails.swift
//  Levy
//
//  Created by Praveenraj T on 07/03/22.
//

import Foundation
struct TripDetails:Hashable{
    let tripID:Int
    var tripName  : String
    var startDate : String
    var myShare = Double(0)
    var groupID = UInt(0)
    var totalExpense = Double(0)
    var friendsCount = UInt(0)

    mutating func updateDetail(with trip:TripDetails){
        self.tripName = trip.tripName
        self.startDate = trip.startDate
        self.myShare = trip.myShare
        self.groupID = trip.groupID
        self.totalExpense = trip.totalExpense
        self.friendsCount = trip.friendsCount
    }
}
