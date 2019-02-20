//
//  ViewController.swift
//  TweetItSweet
//
//  Created by Arjun Baru on 13/02/19.
//  Copyright © 2019 Arjun Baru. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class TweeterSearchListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptySearchLabel: UILabel!
    
    lazy var twitterManager = TwitterManager()
    
    var tweetList = [Tweet]()
    let pendingOperations = PendingOperations()
    let searchController = UISearchController(searchResultsController: nil)
    var indicatorView: NVActivityIndicatorView!
    
    var shouldHideLoadingIndicator: Bool! {
        didSet {
            if shouldHideLoadingIndicator {
                self.indicatorView.isHidden = true
                self.emptySearchLabel.isHidden = false
                self.tableView.isHidden = self.tweetList.isEmpty ? true : false
            } else {
                self.emptySearchLabel.isHidden = true
                self.tableView.isHidden = true
                self.indicatorView.isHidden = false
                self.indicatorView.startAnimating()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.authenticateUser()
        self.configureView()
        self.configureLoadingIndicator()
        
        self.tableView.register(UINib(nibName: "TweetDetailsCell", bundle: nil), forCellReuseIdentifier: "TweetDetails")
        self.tableView.register(TweetDetailsCell.self, forCellReuseIdentifier: "TweetDetailsCell")
    }
    
    func configureView() {
        self.searchController.searchBar.delegate = self
        self.navigationItem.searchController = self.searchController
        self.navigationItem.title = "Tweets"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.backgroundColor = .black
        self.tableView.isHidden = true
    }
    
    private func configureLoadingIndicator() {
        self.indicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80), type: .ballRotate, color: .white)
        self.indicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicatorView)
        
        NSLayoutConstraint.activate ([
            self.indicatorView.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor),
            self.indicatorView.centerYAnchor.constraint(equalTo: self.tableView.centerYAnchor)
            ])
        self.indicatorView.isHidden = true
    }
    
    private func authenticateUser() {
        self.twitterManager.performUserAuthentication { [unowned self] Username, error in
            if let error = error {
                self.showServerAlert(message: error.localizedDescription)
                return
            }
        }
    }
    
    private func fetchTweetList(for searchText: String) {
        self.shouldHideLoadingIndicator = false
        
        self.twitterManager.getSearchStringResult(for: searchText) { [weak self] result, error in
            guard let self = self else { return }
            self.searchController.isActive = false
            
            if let error = error {
                self.showServerAlert(message: error.localizedDescription)
                return
            }
            
            guard let tweetList = result else {
                self.showServerAlert(message: "Unable to read Data")
                return
            }
            
            self.tweetList = tweetList
            self.reloadTableView()
        }
    }
    
    private func reloadTableView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
            self.shouldHideLoadingIndicator = true
            self.tableView.reloadData()
        })
    }
    
    private func showServerAlert(message: String?) {
        self.shouldHideLoadingIndicator = true
        let alert =  UIAlertController(title: "Server Error", message: "Unable to read Data", prefferedStyle: .alert, buttonTitle: "Ok")
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - TableView Datasource methods

extension TweeterSearchListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweetList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetDetails", for: indexPath) as! TweetDetailsCell
        
        cell.shouldStartDownloading = { [weak self] in
            guard let self = self else { return }
            if !tableView.isDragging && !tableView.isDecelerating {
                self.startDownload(for: self.tweetList[indexPath.row], at: indexPath)
            }
        }
        
        cell.tweet = self.tweetList[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    
    //scrollview delegate methods
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
}


extension TweeterSearchListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        pendingOperations.downloadQueue.cancelAllOperations()
        self.fetchTweetList(for: searchText)
    }
}

// MARK: - ImageDownloader Helper

extension TweeterSearchListViewController {
    
    func startDownload(for userImage: Tweet, at indexPath: IndexPath) {
        guard pendingOperations.downloadsInProgress[indexPath] == nil else {
            return
        }
        
        let downloader = ImageDownloader(userImage)
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    func suspendAllOperations() {
        pendingOperations.downloadQueue.isSuspended = true
    }
    
    func resumeAllOperations() {
        pendingOperations.downloadQueue.isSuspended = false
    }
    
    func loadImagesForOnscreenCells() {
        
        if let pathsArray = tableView.indexPathsForVisibleRows {
            let allPendingOperations = Set(pendingOperations.downloadsInProgress.keys)
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray)
            toBeCancelled.subtract(visiblePaths)
            
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)
            
            for indexPath in toBeCancelled {
                
                if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
            }
            
            for indexPath in toBeStarted {
                if tweetList[indexPath.row].state != .downloaded {
                    let imagesToProcess = tweetList[indexPath.row]
                    startDownload(for: imagesToProcess, at: indexPath)
                }
            }
        }
    }
}
