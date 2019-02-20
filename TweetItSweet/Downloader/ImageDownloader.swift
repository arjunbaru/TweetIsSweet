//
//  ImageDownloader.swift
//  TweetItSweet
//
//  Created by Arjun Baru on 14/02/19.
//  Copyright © 2019 Arjun Baru. All rights reserved.
//

//Refered: https://www.raywenderlich.com/5293-operation-and-operationqueue-tutorial-in-swift


import Foundation
import UIKit

protocol ImageDownloaderProtocol {
    var profileImageUrl: URL? { get }
    var profileImage: UIImage? {get set }
    var state: ImageDownloadState {get set}
}

enum ImageDownloadState {
    case new, downloading, downloaded, failed
}

class ImageDownloader: Operation {
    var tweetDetails: ImageDownloaderProtocol
    
    init<T: ImageDownloaderProtocol>(_ tweetDetails: T) {
        self.tweetDetails = tweetDetails
    }
    
    override func main() {
        
        if isCancelled {
            return
        }
        
        guard let imageUrl = tweetDetails.profileImageUrl, let imageData = try? Data(contentsOf: imageUrl) else { return }
        
        if isCancelled {
            return
        }
        
        if !imageData.isEmpty {
            self.tweetDetails.profileImage = UIImage(data:imageData)
            tweetDetails.state = .downloaded
        } else {
            tweetDetails.state = .failed
            tweetDetails.profileImage = UIImage(named: "Failed")
        }
    }
}

class PendingOperations {
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}
