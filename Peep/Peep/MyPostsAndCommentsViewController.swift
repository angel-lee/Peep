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
    
    var userId: NSString!
    
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
            
            self.setArray(self.savedPosts, object: self.posts, index: self.index)
            
            self.tableView.reloadData()
        }
        
        socket.on("loadMyComments") {data, ack in
            self.posts = data?[0] as? NSArray
            
            self.setArray(self.savedPosts, object: self.posts, index: self.index)

            self.tableView.reloadData()
        }
        
        socket.on("loadPostsWithHashtag") {data, ack in
            self.posts = data?[0] as? NSArray
            
            self.setArray(self.savedPosts, object: self.posts, index: self.index)

            self.tableView.reloadData()
        }
    }
    
    func setArray(array: NSMutableArray, object: NSArray, index: Int) {
        array.addObject(object)
        
        self.load = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("load")
        self.navigationController?.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        
        self.socket = app.socket
        self.navigationItem.title = self.navigationTitle
        
        if (serverRequest != "loadPostsWithHashtag") {
            self.socket.emit(serverRequest, app.userId)
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
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(true)
//        print("hey")
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(true)
//        print("disappera")
//    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if((_lastViewController) != nil) {
            _lastViewController.viewWillDisappear(true)
            //print("dissappear")
            self.index = self.index - 1
            if(index == -1) {
                self.savedPosts = []
                //print(savedPosts)
            }
            //print(self.index)
        }
        

        viewController.viewWillAppear(true)
        //print("appear")
        self.index = self.index + 1
        //print(self.index)
        
        _lastViewController = viewController
        if (_lastViewController.isKindOfClass(PostDetailAndCommentViewController)) {
            print("posts")
        }
        
        if (_lastViewController.isKindOfClass(MyProfileTableViewController)) {
            //do stuff
            print("profile")
        }
        
        if (_lastViewController.isKindOfClass(MyPostsAndCommentsViewController)) {
            print("appear")
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showDetailPostAndComments") {
            let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow!
            let cell: PostCellTableViewCell = self.tableView.cellForRowAtIndexPath(indexPath) as! PostCellTableViewCell
            
            let destinationViewController: PostDetailAndCommentViewController = segue.destinationViewController as! PostDetailAndCommentViewController
            
            destinationViewController.detailContent = posts[indexPath.row].valueForKey("content") as! String
            destinationViewController.postId = posts[indexPath.row].valueForKey("_id") as! String
            destinationViewController.originalPosterId = posts[indexPath.row].valueForKey("userId") as! String
            destinationViewController.postLikes = cell.likesInt
            destinationViewController.isLiked = cell.isLiked
        }
    }
    
    func likePost(sender:UIButton) {
        let buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)!
        let cell: PostCellTableViewCell = self.tableView.cellForRowAtIndexPath(indexPath) as! PostCellTableViewCell
        
        let postId: String = self.posts[indexPath.row].valueForKey("_id") as! String
        
        let postIdAndUserId = [
            "postId": postId,
            "userId": app.userId
        ]
        
        if (sender.imageView?.image == UIImage(named: "like.png")) {
            sender.setImage(UIImage(named: "like_filled.png"), forState: UIControlState.Normal)
            
            socket.emit("likePost", postIdAndUserId)
            
            cell.likesInt? += 1
            cell.numOfLikes?.text = String(cell.likesInt)
            cell.isLiked = true
        }
            
        else if (sender.imageView?.image == UIImage(named: "like_filled.png")) {
            sender.setImage(UIImage(named: "like.png"), forState: UIControlState.Normal)
            
            socket.emit("unlikePost", postIdAndUserId)
            
            cell.likesInt? -= 1
            cell.numOfLikes?.text = String(cell.likesInt)
            cell.isLiked = false
        }
    }
    
    func checkIfIveLikedPost(cell: PostCellTableViewCell, item: AnyObject) {
        let likersPerPost: NSArray = item.valueForKey("likers") as! NSArray
        
        if (likersPerPost.containsObject(app.userId)) {
            cell.likeButton.setImage(UIImage(named: "like_filled.png"), forState: UIControlState.Normal)
            cell.isLiked = true
        }
        else {
            cell.likeButton.setImage(UIImage(named: "like.png"), forState: UIControlState.Normal)
            cell.isLiked = false
            
        }
    }
    
    func removeLikeButtonForMyPosts(cell: PostCellTableViewCell, item: AnyObject) {
        let postId: String = item.valueForKey("userId") as! String
        
        if(postId == app.userId) {
            cell.likeButton.enabled = false
        }
        else {
            cell.likeButton.enabled = true
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        let item: AnyObject = self.savedPosts.objectAtIndex(self.index)[indexPath.row]
        self.setPostContentForCell(cell, item: item)
        self.checkIfIveLikedPost(cell, item: item)
        self.removeLikeButtonForMyPosts(cell, item: item)
        
        cell.postContent.handleHashtagTap {
            let hashtag: String = "#\($0.uppercaseString)"
            if hashtag == self.navigationTitle {
                print("cant segue")
            }
            else {
                let hashtagToSend = $0.lowercaseString
            
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let destinationViewController: MyPostsAndCommentsViewController = storyboard.instantiateViewControllerWithIdentifier("alotofviews") as! MyPostsAndCommentsViewController
            
                destinationViewController.serverRequest = "loadPostsWithHashtag"
                destinationViewController.hashtagToSend = hashtagToSend
                destinationViewController.navigationTitle = "#\(hashtagToSend.uppercaseString)"
                self.navigationController?.pushViewController(destinationViewController, animated: true)
            }
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

