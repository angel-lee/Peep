//
//  SearchViewController.swift
//  Peep
//
//  Created by Raymond_Dev on 10/15/15.
//  Copyright © 2015 Rayngel. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {

    var app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var socket: SocketIOClient!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var trendingLabel: UILabel!
    
    var resultSearchController: UISearchController!

    var hashtagsRetrieved: NSArray! = []
    var allHashtags: NSArray! = []
    var searchResults: NSArray! = []
    
    var trendingHashtags: NSArray! = []

    let cellIdentifier: String = "hashtagCell"
    
    var hashtagToSend: String!
    
    var searchBarSpinnerIndicator: UIActivityIndicatorView!
    
    func socketHandlers() {
        socket.on("filterForHashtags") {data, ack in
            
            self.searchResults = data?[0] as? NSArray
            //print("filtering...")
            //print(self.allHashtags)
            
            self.tableView.reloadData()
            self.searchBarSpinnerIndicator.stopAnimating()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBarSpinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        
        self.socket = app.socket
        //socket.emit("getAllHashtags")
        self.socketHandlers()
        
        self.changeTrendingLabel()
        
        resultSearchController = UISearchController()
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.hidesNavigationBarDuringPresentation = false;
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.addSubview(self.searchBarSpinnerIndicator)
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Search Tags"
            self.navigationItem.titleView = controller.searchBar
            self.definesPresentationContext = true
            
            return controller
        })()
        
        self.searchBarSpinnerIndicator.center = CGPointMake(resultSearchController.searchBar.frame.origin.x + resultSearchController.searchBar.frame.size.width/1.7, resultSearchController.searchBar.frame.origin.y + resultSearchController.searchBar.frame.size.height/2)
        
        self.tableView.reloadData()

        // Do any additional setup after loading the view.
    }
    
//    deinit {
//       resultSearchController.loadViewIfNeeded()
//    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(true)
//        self.navigationController?.setToolbarHidden(false, animated: true)
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(true)
//        self.navigationController?.setToolbarHidden(true, animated: true)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        print("change")
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func changeTrendingLabel() {
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.active) {
            self.trendingLabel.text = "FIND TAGS"
            return self.searchResults.count
        }
        else {
            self.trendingLabel.text = "TRENDING TAGS"
            return self.trendingHashtags.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return postCellAtIndexPath(indexPath)

    }
    
    func postCellAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 15)
        
        if (self.resultSearchController.active) {
            cell.textLabel?.text = "#\(searchResults[indexPath.row])"
            
            return cell
        }
        else {
            cell.textLabel?.text = trendingHashtags[indexPath.row] as? String
            
            return cell
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        //if (searchController.searchBar.text != "") {
            //print(searchController.searchBar.text)
        
        if (resultSearchController.active) {
            self.searchBarSpinnerIndicator.startAnimating()
        }
        
        socket.emit("filterForHashtags", (searchController.searchBar.text?.lowercaseString)!)
        //}
        //searchResults.removeAll(keepCapacity: false)
        
        //let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        //print(searchPredicate)
        //let array = allHashtags.filteredArrayUsingPredicate(searchPredicate)
        //searchResults = allHashtags as! [String]
        
        //self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tabBarController?.tabBar.hidden = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc1: MyPostsAndCommentsViewController = storyboard.instantiateViewControllerWithIdentifier("alotofviews") as! MyPostsAndCommentsViewController
        
        if(self.resultSearchController.active) {
            self.hashtagToSend = searchResults[indexPath.row] as! String
        }
        
        vc1.serverRequest = "loadPostsWithHashtag"
        vc1.hashtagToSend = self.hashtagToSend.lowercaseString
        vc1.navigationTitle = "#\(hashtagToSend.uppercaseString)"
        
        //self.resultSearchController.active = false
        self.navigationController?.pushViewController(vc1, animated: true)
    }
    


}
