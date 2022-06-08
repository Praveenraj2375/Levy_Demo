//
//  NetwrokMoniter.swift
//  Levy
//
//  Created by Praveenraj T on 25/04/22.
//

import Foundation
import Network

func isConnectedToInternet( onCompletion:@escaping (Bool)->Void){
    let moniter = NWPathMonitor()
    moniter.pathUpdateHandler = { path in
        if path.status == .satisfied{
            onCompletion(true)
            moniter.cancel()
        }else{
            onCompletion(false)
            moniter.cancel()
        }
    }
    let queue = DispatchQueue.global()
    moniter.start(queue: queue)
}
