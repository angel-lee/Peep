//
//  FirstViewController.swift
//  Peep
//
//  Created by Raymond_Dev on 8/28/15.
//  Copyright (c) 2015 Rayngel. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift
import ActiveLabel

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
        
    var app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    let cellIdentifier: String = "postContentCell"
    
    var deviceId: String!
   
    var posts: NSArray! = []
    
    let hashtagRegex = "#[A-Za-z0-9]+"
    //let hashtagRegex = "\\s*#(?:\\[[^\\]]+\\]|\\s+)"
    
    let socket = SocketIOClient(socketURL: "localhost:8000")
    //let socket = SocketIOClient(socketURL: "http://ec2-52-89-43-120.us-west-2.compute.amazonaws.com:8080")
    
    var hashtagToSend: String!
    
    func socketHandlers() {
        socket.on("connect") {data, ack in
            print("connected to ec2:8080")
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
        
        self.deviceId = UIDevice.currentDevice().identifierForVendor!.UUIDString
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showDetailPostAndComments") {
            let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow!
            let destinationViewController: PostDetailAndCommentViewController = segue.destinationViewController as! PostDetailAndCommentViewController
            
            destinationViewController.detailContent = posts[indexPath.row].valueForKey("content") as! String
            //destinationViewController.comments = posts[indexPath.row].valueForKey("comments") as! NSArray
            destinationViewController.postId = posts[indexPath.row].valueForKey("_id") as! String
            destinationViewController.originalPosterId = posts[indexPath.row].valueForKey("userId") as! String
            destinationViewController.postLikes = posts[indexPath.row].valueForKey("likes") as! Int
            //destinationViewController.postLikers = posts[indexPath.row].valueForKey("likers") as! NSArray
            
            //destinationViewController.hidesBottomBarWhenPushed = true
        }
        else if(segue.identifier == "loadHashtags") {
            let destinationViewController: MyPostsAndCommentsViewController = segue.destinationViewController as! MyPostsAndCommentsViewController
            destinationViewController.serverRequest = "loadPostsWithHashtag"
            destinationViewController.hashtagToSend = self.hashtagToSend
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
        let likersPerPost: NSArray = item.valueForKey("likers") as! NSArray
        
        if (likersPerPost.containsObject(app.deviceId)) {
            cell.likeButton.setTitle("unlike", forState: UIControlState.Normal)
        }
        else {
            cell.likeButton.setTitle("like", forState: UIControlState.Normal)
        }
    }
    
    func removeLikeButtonForMyPosts(cell: PostCellTableViewCell, item: AnyObject) {
        let postId: String = item.valueForKey("userId") as! String
        
        if(postId == app.deviceId) {
            cell.likeButton.enabled = false
            cell.likeButton.hidden = true
        }
        else {
            cell.likeButton.enabled = true
            cell.likeButton.hidden = false
        }
    }
    
    func setupGestureRecognizerForContentLabel(cell: PostCellTableViewCell) {
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "labelTapped:")
        
        cell.postContent.userInteractionEnabled = true
        cell.postContent.addGestureRecognizer(gesture)
    }
    
    func labelTapped(sender: AnyObject) {
        print("tapped label")
        
    }
    
    func findHashtags(cell: PostCellTableViewCell, item: AnyObject) {
        var regex: NSRegularExpression = NSRegularExpression()
                
        let cellContentString: String = (cell.postContent?.text)!
        
        let string = NSMutableAttributedString(string: cell.postContent.text!)
        
        do {
            regex = try NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpressionOptions.CaseInsensitive)
        }
        catch {}
        
        let matches: NSArray = regex.matchesInString(cellContentString, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, cellContentString.characters.count))
        
        for match: NSTextCheckingResult in matches as! [NSTextCheckingResult] {
            let wordRange: NSRange = match.rangeAtIndex(0)
            
            string.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: wordRange)
    }
        
        cell.postContent?.attributedText = string
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
        
        cell.likeButton.addTarget(self, action: "likePost:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
        
    }
    
    func configureBasicCell(cell: PostCellTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let item: AnyObject = self.posts[indexPath.row]
        self.setPostContentForCell(cell, item: item)
        self.checkIfIveLikedPost(cell, item: item)
        self.removeLikeButtonForMyPosts(cell, item: item)
        //self.findHashtags(cell, item: item)
        //self.setupGestureRecognizerForContentLabel(cell)
        cell.postContent.handleHashtagTap {
            self.hashtagToSend = $0
            //print(self.hashtagToSend)
            self.performSegueWithIdentifier("loadHashtags", sender: self)
        }
    }
    
    func setPostContentForCell(cell: PostCellTableViewCell, item: AnyObject) {
        let content: String = item.valueForKey("content") as! String
        cell.likesInt = item.valueForKey("likes") as! Int
                
        cell.postContent?.text = content
        cell.numOfLikes?.text = String(cell.likesInt)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print("You selected cell #\(indexPath.row)!")
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

