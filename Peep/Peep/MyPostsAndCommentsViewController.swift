//
//  SecondViewController.swift
//  Peep
//
//  Created by Raymond_Dev on 8/28/15.
//  Copyright (c) 2015 Rayngel. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift


class MyPostsAndCommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!

    var app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let cellIdentifier: String = "myCommentAndPostContentCell"

    var socket: SocketIOClient!
    
    var deviceId: String!
    
    var posts: NSArray! = []
    
    var serverRequest: String!
    
    var hashtagToSend: String!

    func socketHandlers() {
        socket.on("loadMyPosts") {data, ack in
            self.posts = data?[0] as? NSArray
            
            self.tableView.reloadData()
        }
        
        socket.on("loadMyComments") {data, ack in
            self.posts = data?[0] as? NSArray
            
            self.tableView.reloadData()
        }
        
        socket.on("loadPostsWithHashtag") {data, ack in
            self.posts = data?[0] as? NSArray
            
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.socket = app.socket
        
        if (serverRequest != "loadPostsWithHashtag") {
            self.socket.emit(serverRequest, app.deviceId)
        }
            
        else {
           self.socket.emit(serverRequest, hashtagToSend)
        }
        
        socketHandlers()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.posts.count
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
//        
//        cell.textLabel?.text = self.posts[indexPath.row].valueForKey("content") as? String
//
//        return cell
//    }
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        println("You selected cell #\(indexPath.row)!")
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showDetailPostAndComments") {
            let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow!
            let destinationViewController: PostDetailAndCommentViewController = segue.destinationViewController as! PostDetailAndCommentViewController
            
            destinationViewController.detailContent = posts[indexPath.row].valueForKey("content") as! String
            //destinationViewController.comments = posts[indexPath.row].valueForKey("comments") as! NSArray
            destinationViewController.postId = posts[indexPath.row].valueForKey("_id") as! String
            destinationViewController.originalPosterId = posts[indexPath.row].valueForKey("userId") as! String
            //destinationViewController.hidesBottomBarWhenPushed = true
        }
    }
    
    func checkIfIveLikedPost(cell: PostCellTableViewCell, item: AnyObject) {
        let likersPerPost: NSArray = item.valueForKey("likers") as! NSArray
        
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
        let cell:PostCellTableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PostCellTableViewCell
        
        self.configureBasicCell(cell, atIndexPath: indexPath)
        
        return cell
        
    }
    
    func configureBasicCell(cell: PostCellTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let item: AnyObject = self.posts[indexPath.row]
        self.setPostContentForCell(cell, item: item)
        self.checkIfIveLikedPost(cell, item: item)
    }
    
    func setPostContentForCell(cell: PostCellTableViewCell, item: AnyObject) {
        let content: String = item.valueForKey("content") as! String
        let numLikes: Int = item.valueForKey("likes") as! Int
        
        cell.postContent?.text = content
        cell.numOfLikes?.text = String(numLikes)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
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
        
        let size: CGSize = sizingCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height
    }


}

