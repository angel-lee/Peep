//
//  FirstViewController.swift
//  Peep
//
//  Created by Raymond_Dev on 8/28/15.
//  Copyright (c) 2015 Rayngel. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
        
    var app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    let cellIdentifier: String = "postContentCell"
    
    var deviceId: String!
   
    var posts: NSArray! = []
    
    let socket = SocketIOClient(socketURL: "localhost:8000")
    
    func socketHandlers() {
        socket.on("connect") {data, ack in
            println("connected to localhost:8000")
        }
        
        socket.on("loadPosts") {data, ack in
            self.posts = data?[0] as? NSArray
            
            self.tableView.reloadData()            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        app.socket = self.socket
        
        self.deviceId = UIDevice.currentDevice().identifierForVendor.UUIDString
        app.deviceId = self.deviceId
        
        socketHandlers()
        self.socket.connect()
        
        //self.tableView.estimatedRowHeight = 200
        
        //self.tableView.registerClass(PostCellTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        socket.emit("reloadPosts")
        refreshControl.endRefreshing()
    }
    
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "newPost") {
            let nav = segue.destinationViewController as! UINavigationController
            let postViewController = nav.topViewController as! PostViewController
            
            postViewController.toReceive = self.socket
            postViewController.deviceIdToRecieve = self.deviceId
        }
    }*/
    
    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        var cell:PostCellTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("postContentCell") as! UITableViewCell
//        
//        //cell.textLabel?.text = self.posts[indexPath.row].valueForKey("content") as? String
//        cell.postContent?.text = self.posts[indexPath.row] as? String
//
//        
//        return cell
//    }
    
    func likePost(sender:UIButton) {
        var buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        var indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)!
        var cell: PostCellTableViewCell = self.tableView.cellForRowAtIndexPath(indexPath) as! PostCellTableViewCell
        
        var postId: String = self.posts[indexPath.row].valueForKey("_id") as! String
        
        var postIdAndUserId = [
            "postId": postId,
            "userId": app.deviceId
        ]
        
        if (sender.titleLabel?.text == "like") {
            sender.setTitle("unlike", forState: UIControlState.Normal)
            
            socket.emit("likePost", postIdAndUserId)
            
            cell.likesInt? += 1
            cell.numOfLikes?.text = String(cell.likesInt)
        }
            
        else if (sender.titleLabel?.text == "unlike") {
            sender.setTitle("like", forState: UIControlState.Normal)

            socket.emit("unlikePost", postIdAndUserId)
            
            cell.likesInt? -= 1
            cell.numOfLikes?.text = String(cell.likesInt)
        }
    }
    
    func checkIfIveLikedPost(cell: PostCellTableViewCell, item: AnyObject) {
        println("checkIfIveLikedPosts")
        
        var likersPerPost: NSArray = item.valueForKey("likers") as! NSArray
        println(likersPerPost)
        
        if (likersPerPost.containsObject(app.deviceId)) {
            cell.likeButton.setTitle("unlike", forState: UIControlState.Normal)
        }
        else {
            cell.likeButton.setTitle("like", forState: UIControlState.Normal)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return postCellAtIndexPath(indexPath)
    }
    
    func postCellAtIndexPath(indexPath: NSIndexPath) -> PostCellTableViewCell {
        var cell:PostCellTableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PostCellTableViewCell
        
        self.configureBasicCell(cell, atIndexPath: indexPath)
        
        cell.likeButton.addTarget(self, action: "likePost:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
        
    }
    
    func configureBasicCell(cell: PostCellTableViewCell, atIndexPath indexPath: NSIndexPath) {
        var item: AnyObject = self.posts[indexPath.row]
        self.setPostContentForCell(cell, item: item)
        self.checkIfIveLikedPost(cell, item: item)
    }
    
    func setPostContentForCell(cell: PostCellTableViewCell, item: AnyObject) {
        var content: String = item.valueForKey("content") as! String
        cell.likesInt = item.valueForKey("likes") as! Int
        
        cell.postContent?.text = content
        cell.numOfLikes?.text = String(cell.likesInt)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return heightForBasicCellAtIndexPath(indexPath)
    }
    
    func heightForBasicCellAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        var sizingCell: PostCellTableViewCell!
        var token: dispatch_once_t = 0
        
        dispatch_once(&token, { () -> Void in
            sizingCell = self.tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as! PostCellTableViewCell
        })
        
        self.configureBasicCell(sizingCell, atIndexPath: indexPath)
        return self.calculateHeightForConfiguredSizingCell(sizingCell)
    }
    
    func calculateHeightForConfiguredSizingCell(sizingCell: UITableViewCell) -> CGFloat {
        sizingCell.setNeedsLayout()
        sizingCell.layoutIfNeeded()
        
        var size: CGSize = sizingCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height
    }
    
}

