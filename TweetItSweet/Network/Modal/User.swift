//
//  User.swift
//  TweetItSweet
//
//  Created by Arjun Baru on 14/02/19.
//  Copyright © 2019 Arjun Baru. All rights reserved.
//

import Foundation
import UIKit

class User: Decodable {
    var name: String
    var handle: String
    var profileImageUrl: URL?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.handle = try container.decode(String.self, forKey: .handle)
        self.profileImageUrl = try container.decodeIfPresent(URL.self, forKey: .profileImageUrl)
    }
    
    enum CodingKeys : String,CodingKey {
        case name = "name"
        case handle = "screen_name"
        case profileImageUrl = "profile_image_url_https"
    }
}
