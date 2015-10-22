//
//  SecondViewController.swift
//  Peep
//
//  Created by Raymond_Dev on 8/28/15.
//  Copyright (c) 2015 Rayngel. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift


class MyPostsAndCommentsViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!

    var app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let cellIdentifier: String = "myCommentAndPostContentCell"

    var socket: SocketIOClient!
    
    var deviceId: String!
    
    var posts: NSArray! = []
    
    var savedArrayOfPosts: NSArray! = []
    
    var serverRequest: String!
    
    var hashtagToSend: String!
    
    var navigationTitle: String!
    
    var savedPosts: NSMutableArray! = []
    
    var load: Bool! = false
    
    var index: Int! = -1
    
    var _lastViewController: UIViewController!
    
    func socketHandlers() {
        socket.on("loadMyPosts") {data, ack in
            self.posts = data?[0] as? NSArray
            //print("set posts")
            
            //self.savedPosts.insertObject(self.posts, atIndex: (self.navigationController?.viewControllers.indexOf(self))! - 1)
            self.setArray(self.savedPosts, object: self.posts, index: self.index)
            
            //print(self.savedPosts.objectAtIndex(0))
            
            self.tableView.reloadData()
        }
        
        socket.on("loadMyComments") {data, ack in
            self.posts = data?[0] as? NSArray
            
            //self.savedPosts.insertObject(self.posts, atIndex: (self.navigationController?.viewControllers.indexOf(self))! - 1)
            self.setArray(self.savedPosts, object: self.posts, index: self.index)


            self.tableView.reloadData()
        }
        
        socket.on("loadPostsWithHashtag") {data, ack in
            self.posts = data?[0] as? NSArray
            
            //self.savedPosts.insertObject(self.posts, atIndex: (self.navigationController?.viewControllers.indexOf(self))! - 1)
            self.setArray(self.savedPosts, object: self.posts, index: self.index)


            self.tableView.reloadData()
        }
    }
    
    func setArray(array: NSMutableArray, object: NSArray, index: Int) {
        array.addObject(object)
        //print(array)
        //print("set array")
        self.load = true
        //self.load = true
        //self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("load")
        self.navigationController?.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.socket = app.socket
        self.navigationItem.title = self.navigationTitle
        
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
    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(true)
//        print("view disappear")
//        self.load = false
//        //print(self.load)
//        self.index = self.index - 1
//        print("index:  \(self.index)")
//        if(index == -1) {
//            self.savedPosts = []
//            print(savedPosts)
//        }
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(true)
//        print("view appear")
//        //print(self.load)
//        self.index = self.index + 1
//        print("index:  \(self.index)")
//        //print((self.navigationController?.viewControllers.indexOf(self))! - 1)
//    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if((_lastViewController) != nil) {
            _lastViewController.viewWillDisappear(true)
            print("dissappear?")
            self.index = self.index - 1
            if(index == -1) {
                self.savedPosts = []
                print(savedPosts)
            }
            print(self.index)
        }
        
        viewController.viewWillAppear(true)
        print("appear?")
        self.index = self.index + 1
        print(self.index)
        
//        if(_lastViewController.isKindOfClass(MyProfileTableViewController)) {
//            _lastViewController = viewController as! MyProfileTableViewController
//        }
        _lastViewController = viewController
        if (_lastViewController.isKindOfClass(MyPostsAndCommentsViewController)) {
            //print(_lastViewController)
            //do stuff
        }
            //_lastViewController = viewController as! MyPostsAndCommentsViewController
        //viewController.navigationController?.popToRootViewControllerAnimated(true)
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
            let cell: PostCellTableViewCell = self.tableView.cellForRowAtIndexPath(indexPath) as! PostCellTableViewCell
            
            let destinationViewController: PostDetailAndCommentViewController = segue.destinationViewController as! PostDetailAndCommentViewController
            
            //self.hideTabBar(self.tabBarController!)
            
            //self.tabBarController?.tabBar.hidden = true
            
            destinationViewController.detailContent = posts[indexPath.row].valueForKey("content") as! String
            //destinationViewController.comments = posts[indexPath.row].valueForKey("comments") as! NSArray
            destinationViewController.postId = posts[indexPath.row].valueForKey("_id") as! String
            destinationViewController.originalPosterId = posts[indexPath.row].valueForKey("userId") as! String
            //destinationViewController.postLikes = posts[indexPath.row].valueForKey("likes") as! Int
            destinationViewController.postLikes = cell.likesInt
            // destinationViewController.indexPath = indexPath
            destinationViewController.isLiked = cell.isLiked
            
            //destinationViewController.postLikers = posts[indexPath.row].valueForKey("likers") as! NSArray
        }
    }
    
    func likePost(sender:UIButton) {
        let buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)!
        let cell: PostCellTableViewCell = self.tableView.cellForRowAtIndexPath(indexPath) as! PostCellTableViewCell
        
        let postId: String = self.posts[indexPath.row].valueForKey("_id") as! String
        
        let postIdAndUserId = [
            "postId": postId,
            "userId": app.deviceId
        ]
        
        if (sender.imageView?.image == UIImage(named: "like.png")) {
            //sender.setTitle("unlike", forState: UIControlState.Normal)
            sender.setImage(UIImage(named: "like_filled.png"), forState: UIControlState.Normal)
            
            socket.emit("likePost", postIdAndUserId)
            
            cell.likesInt? += 1
            cell.numOfLikes?.text = String(cell.likesInt)
            cell.isLiked = true
        }
            
        else if (sender.imageView?.image == UIImage(named: "like_filled.png")) {
            //sender.setTitle("like", forState: UIControlState.Normal)
            sender.setImage(UIImage(named: "like.png"), forState: UIControlState.Normal)
            
            
            socket.emit("unlikePost", postIdAndUserId)
            
            cell.likesInt? -= 1
            cell.numOfLikes?.text = String(cell.likesInt)
            cell.isLiked = false
        }
    }
    
    func checkIfIveLikedPost(cell: PostCellTableViewCell, item: AnyObject) {
        let likersPerPost: NSArray = item.valueForKey("likers") as! NSArray
        
        if (likersPerPost.containsObject(app.deviceId)) {
            //cell.likeButton.setTitle("unlike", forState: UIControlState.Normal)
            cell.likeButton.setImage(UIImage(named: "like_filled.png"), forState: UIControlState.Normal)
            cell.isLiked = true
            
        }
        else {
            //cell.likeButton.setTitle("like", forState: UIControlState.Normal)
            cell.likeButton.setImage(UIImage(named: "like.png"), forState: UIControlState.Normal)
            cell.isLiked = false
            
        }
    }
    
    func removeLikeButtonForMyPosts(cell: PostCellTableViewCell, item: AnyObject) {
        let postId: String = item.valueForKey("userId") as! String
        
        if(postId == app.deviceId) {
            cell.likeButton.enabled = false
            //cell.likeButton.hidden = true
        }
        else {
            cell.likeButton.enabled = true
            //cell.likeButton.hidden = false
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("loaded table view")
        //print(self.posts.count)
        //return self.posts.count
        //return self.savedPosts.objectAtIndex((self.navigationController?.viewControllers.indexOf(self))! - 1).count
        if(self.load == true && self.index >= 0) {
            return self.savedPosts.objectAtIndex(self.index).count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return postCellAtIndexPath(indexPath)
    }
    
    func postCellAtIndexPath(indexPath: NSIndexPath) -> PostCellTableViewCell {
        let cell:PostCellTableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PostCellTableViewCell
        
        cell.likeButton.addTarget(self, action: "likePost:", forControlEvents: UIControlEvents.TouchUpInside)

        
        self.configureBasicCell(cell, atIndexPath: indexPath)
        
        return cell
        
    }
    
    func configureBasicCell(cell: PostCellTableViewCell, atIndexPath indexPath: NSIndexPath) {
        //print("configure cell")
        //let item: AnyObject = self.posts[indexPath.row]
        let item: AnyObject = self.savedPosts.objectAtIndex(self.index)[indexPath.row]
        self.setPostContentForCell(cell, item: item)
        self.checkIfIveLikedPost(cell, item: item)
        self.removeLikeButtonForMyPosts(cell, item: item)
        
        cell.postContent.handleHashtagTap {
            //self.load = false
//            self.index = self.index + 1
//            print("index: \(self.index)")
            let hashtagToSend = $0
            //print(self.hashtagToSend)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationViewController: MyPostsAndCommentsViewController = storyboard.instantiateViewControllerWithIdentifier("alotofviews") as! MyPostsAndCommentsViewController
            destinationViewController.serverRequest = "loadPostsWithHashtag"
            destinationViewController.hashtagToSend = hashtagToSend
            destinationViewController.navigationTitle = "#\(hashtagToSend)"
            self.navigationController?.pushViewController(destinationViewController, animated: true)
            //self.performSegueWithIdentifier("loadHashtags", sender: self)
        }
    }
    
    func setPostContentForCell(cell: PostCellTableViewCell, item: AnyObject) {
        let content: String = item.valueForKey("content") as! String
        
        let numOfComments = item.valueForKey("comments")?.count
        cell.numOfComments.text = Utilities().countComments(numOfComments!)
        
        cell.likesInt = item.valueForKey("likes") as! Int
        
        cell.postContent?.text = content
        cell.numOfLikes?.text = String(cell.likesInt)
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

