//
//  LevyError.swift
//  Levy
//
//  Created by Praveenraj T on 27/04/22.
//

import Foundation
enum LevyError: Error {
    case urlCreationFailed
    case urlSessionError
    case noInternetConnection
    case poorInternerConnection
    case lostNetworkConnection
    case unknown

}
extension LevyError{
    public var errorDescription: String? {
        switch self {
        
        case .urlCreationFailed:
            return "Something went wrong.Please try after some time \nLevy_URLCreation"
        
        case .urlSessionError:
            return "Something went wrong.Please try after some time \nLevy_URLSession"
        
        case .noInternetConnection:
            return "No internet connection"
        
        case .poorInternerConnection:return "Slow internet connection. Try after sometime"
        
        case .lostNetworkConnection:return "Unexpectedly server connection terminated.Please try after some time"
        
        default : return "Some thing went wrong.Please try after some time \nLevy_Unknown"
        }
    }
}
