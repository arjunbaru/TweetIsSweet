//
//  TwitterManager.swift
//  TweetItSweet
//
//  Created by Arjun Baru on 13/02/19.
//  Copyright © 2019 Arjun Baru. All rights reserved.
//

import Foundation

class TwitterManager {
    var twitter: STTwitterAPI
    
    init() {
        self.twitter = STTwitterAPI(oAuthConsumerKey: "8QGWyrk4id2IXZprhvuT2zmJz", consumerSecret: "zPoDnDWnyiiCug7HB68xfTowSy7A0dP4S9hbXmyFePPApUCUeM", oauthToken: "1095726404354826240-6NOPfwbusu1TvjxnRYXbND50EArGfT", oauthTokenSecret: "37ui6ppk0CVWBXmWMJW3eLFaQyxWkvMomLQ4ru6b4wHZE")
    }
    
    func authenticateUser(completion: @escaping((String?, Error?) -> Void)) {
        self.twitter.verifyCredentials(userSuccessBlock: { (userName, userId) in
            completion(userName ?? "", nil)
        }) { error in
            completion("", error)
        }
    }
    
    func getSearchResult(searchQuerry: String, completion: @escaping(([Tweet]?, Error?)  -> Void)) {
        
        self.twitter.getSearchTweets(withQuery: searchQuerry, successBlock: { (response, result) in
            if let _ = result as? [[String: Any]] {
                do {
                    let data = try JSONSerialization.data(withJSONObject: result!, options: .prettyPrinted)
                    let tweets = try JSONDecoder().decode([Tweet].self, from: data)
                    completion(tweets, nil)
                } catch {
                    print(error)
                }
            }
        }) { error in
            completion(nil, error)
        }
    }
}
