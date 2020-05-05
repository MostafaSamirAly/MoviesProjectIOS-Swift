//
//  JsonHelper.swift
//  MoviesProject
//
//  Created by Mostafa Samir on 1/2/20.
//  Copyright © 2020 Mostafa Samir. All rights reserved.
//

import UIKit
import Alamofire
import ReachabilitySwift

class JsonHelper {
    static let jsonHelperSingleTone = JsonHelper()

    var connected : Bool?
    private init(){}
    
    
    func getMovies(url: String, completion: @escaping ([Dictionary<String,Any>]) -> ())
    {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        Alamofire.request(url).validate().responseJSON() { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = value as! Dictionary<String,Any>
                    completion((json["results"] as? [Dictionary<String,Any>])!)
                }
            case .failure(let error):
                print(error)
                completion([])
            }
        }
    }
    
    func checkReachability(completion:@escaping(Bool)->()){
        let reachability = Reachability()!
        reachability.whenReachable = { _ in
                completion(true)
            
        }
        reachability.whenUnreachable = { _ in
            completion(false)
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    }
}
