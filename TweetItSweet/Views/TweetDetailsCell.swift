//
//  TweetDetailsCell.swift
//  TweetItSweet
//
//  Created by Arjun Baru on 14/02/19.
//  Copyright © 2019 Arjun Baru. All rights reserved.
//

import UIKit

class TweetDetailsCell: UITableViewCell {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userHandelLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favouriteCountLabel: UILabel!
    @IBOutlet weak var tweetDescriptionLabel: UILabel!
    
    var shouldStartDownloading: (() -> Void)?
    var didEndDownloading: (() -> Void)?
        
    var tweet: Tweet? {
        didSet {
            self.reset()
            
            self.retweetCountLabel.text = self.tweet?.getFavouriteCount
            self.favouriteCountLabel.text = self.tweet?.getRetweetCount
            self.tweetDescriptionLabel.text = self.tweet?.tweetDescription
            self.userNameLabel.text = self.tweet?.user.name
            self.userHandelLabel.text = self.tweet?.getUserHandle
        
            self.tweetDescriptionLabel.clipsToBounds = true
            
            // Loading user Image
            switch self.tweet?.state {
            case .new?:
                self.loadingIndicator.isHidden = false
                self.loadingIndicator.startAnimating()
                self.userImageView.image = self.tweet?.profileImage
                self.shouldStartDownloading?()
            case .downloaded?:
                self.loadingIndicator.isHidden = true
                self.userImageView.image = self.tweet?.profileImage
            case .failed?:
                self.loadingIndicator.isHidden = true
                self.userImageView.image = self.tweet?.profileImage
            default:
                print("Nothing")
            }
        }
    }
    
    private func reset() {
        self.userImageView.image = nil
        self.retweetCountLabel.text = nil
        self.userNameLabel.text = nil
        self.userHandelLabel.text = nil
    }
}
