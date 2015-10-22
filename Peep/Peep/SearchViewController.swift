//
//  SearchViewController.swift
//  Peep
//
//  Created by Raymond_Dev on 10/15/15.
//  Copyright © 2015 Rayngel. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    var app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var socket: SocketIOClient!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var trendingLabel: UILabel!
    
    var resultSearchController: UISearchController!

    var hashtagsRetrieved: NSArray! = []
    var allHashtags: NSArray! = []
    var searchResults = [String]()
    
    var trendingHashtags: NSArray! = []

    let cellIdentifier: String = "hashtagCell"
    
    var hashtagToSend: String!
    
    func socketHandlers() {
        socket.on("getAllHashtags") {data, ack in
            
            self.allHashtags = data?[0] as? NSArray
            
            print(self.allHashtags)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.socket = app.socket
        socket.emit("getAllHashtags")
        self.socketHandlers()
        
        self.changeTrendingLabel()
        
        resultSearchController = UISearchController()

        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            //controller.definesPresentationContext = true
            controller.searchResultsUpdater = self
            controller.hidesNavigationBarDuringPresentation = false;
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Search Tags"
            
            //self.tableView.tableHeaderView = controller.searchBar
            self.navigationItem.titleView = controller.searchBar
            
            return controller
        })()
        
        self.tableView.reloadData()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

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
            self.trendingLabel.text = "FIND"
            return self.searchResults.count
        }
        else {
            self.trendingLabel.text = "TRENDING"
            return self.trendingHashtags.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return postCellAtIndexPath(indexPath)

    }
    
    func postCellAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        if (self.resultSearchController.active) {
            cell.textLabel?.text = searchResults[indexPath.row]
            
            return cell
        }
        else {
            cell.textLabel?.text = trendingHashtags[indexPath.row] as? String
            
            return cell
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        searchResults.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = allHashtags.filteredArrayUsingPredicate(searchPredicate)
        searchResults = array as! [String]
        
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tabBarController?.tabBar.hidden = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc1: MyPostsAndCommentsViewController = storyboard.instantiateViewControllerWithIdentifier("alotofviews") as! MyPostsAndCommentsViewController
        
        if(self.resultSearchController.active) {
            self.hashtagToSend = searchResults[indexPath.row]
        }
        
        //vc1.hidesBottomBarWhenPushed = true
        vc1.serverRequest = "loadPostsWithHashtag"
        vc1.hashtagToSend = self.hashtagToSend
        vc1.navigationItem.title = "#\(hashtagToSend)"
        self.resultSearchController.active = false
        self.navigationController?.pushViewController(vc1, animated: true)
    }
    


}
