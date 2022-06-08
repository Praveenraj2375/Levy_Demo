//
//  URLSessionDelegate.swift
//  Levy
//
//  Created by Praveenraj T on 18/04/22.
//

import Foundation
import UIKit
struct NetworkHelper{
    //static var count:Int = 0
    static func willGetImageFromServer(for url:String,cache:NSCache<AnyObject, AnyObject>? = nil,searchText:String = "",onCompletion:@escaping(UIImage?,LevyError?,String,Bool?)->Void){

        DispatchQueue.global().async {
            getImage(for: url,searchText:searchText, cache: cache,onCompletion: {image,error,searchText,isFromCache in
                onCompletion(image,error,searchText,isFromCache)
            })
        }
        
    }
    
    private static func getImage(for urlString:String,searchText:String,cache:NSCache<AnyObject, AnyObject>? = nil, onCompletion:@escaping(UIImage?,LevyError?,String,Bool?)->Void){
        

                              
        if let cachedImage = cache?.object(forKey: urlString as AnyObject)as? UIImage{
            DispatchQueue.main.async {
                debugPrint("image from cache")
                onCompletion(cachedImage,nil,searchText,true)
                return
            }
            return
        }
        
        guard let url = URL(string: urlString) else{
             onCompletion(nil,.urlCreationFailed,searchText,nil)
            return
        }
        
        let urlSession = URLSession.shared
        urlSession.configuration.timeoutIntervalForResource = 1
        
        urlSession.dataTask(with: url, completionHandler:{data,response,error in

            guard let data = data,error == nil else{
                guard let error = error else {
                    return
                }
                
                switch (error as NSError).code{
                case URLError.Code.notConnectedToInternet.rawValue:onCompletion(nil,.noInternetConnection,searchText,nil)
                case URLError.Code.timedOut.rawValue: onCompletion(nil,.poorInternerConnection,searchText,nil)
                case URLError.Code.badURL.rawValue: onCompletion(nil,.urlCreationFailed,searchText,nil)
                case URLError.Code.networkConnectionLost.rawValue: onCompletion(nil,.lostNetworkConnection,searchText,nil)
                case URLError.Code.unknown.rawValue:onCompletion(nil,.unknown,searchText,nil)
                default:onCompletion(nil,.unknown,searchText,nil)
                }

                return
            }
            
            if let image = UIImage(data: data){
            DispatchQueue.main.async {
                debugPrint("image form server")
                onCompletion(image, nil,searchText,false)
            }
                
            }
        }).resume()
    }
}
