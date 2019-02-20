//
//  TwitterManager+Extension.swift
//  TweetItSweet
//
//  Created by Arjun Baru on 14/02/19.
//  Copyright © 2019 Arjun Baru. All rights reserved.
//

import Foundation


extension TwitterManager {
    
    public func performUserAuthentication(completion: @escaping((String?, Error?) -> Void)) {
        self.authenticateUser(completion: completion)
    }
    
    public func getSearchStringResult(for querry: String, completion: @escaping ([Tweet]?, Error?) -> Void) {
        self.getSearchResult(searchQuerry: querry, completion: completion)
    }
}
