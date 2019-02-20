//
//  Tweet.swift
//  TweetItSweet
//
//  Created by Arjun Baru on 13/02/19.
//  Copyright © 2019 Arjun Baru. All rights reserved.
//

import Foundation
import UIKit

class Tweet: Decodable, ImageDownloaderProtocol {

    var retweetCount: Int
    var favouriteCount: Int
    var tweetDescription: String
    var user: User
    var profileImage: UIImage? = UIImage(named: "Placeholder")
    var state: ImageDownloadState = .new
    
    var profileImageUrl: URL? {
        return self.user.profileImageUrl
    }
    
    var getUserHandle: String? {
        return "@" + self.user.handle
    }
    
    var getFavouriteCount: String? {
       return String(self.favouriteCount)
    }
    
    var getRetweetCount: String? {
        return String(self.retweetCount)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.retweetCount = try container.decode(Int.self, forKey: .retweetCount)
        self.favouriteCount = try container.decode(Int.self, forKey: .favouriteCount)
        self.tweetDescription = try container.decode(String.self, forKey: .tweetDescription)
        self.user = try container.decode(User.self, forKey: .user)
    }
    
    enum CodingKeys : String,CodingKey {
        case retweetCount = "retweet_count"
        case favouriteCount = "favorite_count"
        case tweetDescription = "text"
        case user
    }
}
