//
//  PostDetailAndCommentViewController.swift
//  Peep
//
//  Created by Raymond_Dev on 9/20/15.
//  Copyright © 2015 Rayngel. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift
import ActiveLabel

class PostDetailAndCommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    var app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var socket: SocketIOClient!
    
    var hashtagToSend: String!
    
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var detailContentLabel: ActiveLabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var postCommentButton: UIBarButtonItem!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    var detailContent: String!
    
    var comments: NSArray! = []
    
    let cellIdentifier: String = "commentContentCell"

    var deviceId: String!
    
    var postId: String!
    
    var originalPosterId: String!
    
    var postLikes: Int!
    
    var thePost: AnyObject!
    
    var postLikers: NSArray! = []
    
    var buttonString: String!
    
    var isLiked: Bool!
    
    var commentTextView: UITextView!

    func socketHandlers() {
        socket.on("loadComments") {data, ack in
            
            self.comments = data?[0] as? NSArray
            
            self.commentTableView.reloadData()
        }
        
        socket.on("commentSaved") {data, ack in
            self.comments = data?[0] as? NSArray
            
            self.commentTableView.reloadData()
        }
        
        socket.on("getThePost") {data, ack in

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        detailContentLabel.numberOfLines = 0
        detailContentLabel.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
        
        likeButton.addTarget(self, action: "likePost:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.deviceId = app.deviceId
        self.socket = app.socket
        
        socketHandlers()
        
        socket.emit("loadComments", self.postId)
        socket.emit("getThePost", self.postId)
        
        
        detailContentLabel.text = detailContent
        likesLabel.text = String(postLikes)
        
        removeLikeButtonForMyPosts()
        setLikeButtonStateOnLoad()
        
        //self.commentTableView.keyboardDismissMode = .OnDrag
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        commentTextView = UITextView(frame: CGRectMake(0,0,self.view.frame.width - (self.view.frame.width/5),32))
        commentTextView.delegate = self
        commentTextView.font = UIFont(name: "Helvetica Neue", size: 15)
        commentTextView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.borderColor = UIColor.grayColor().CGColor
        commentTextView.layer.cornerRadius = 5
        
        let commentTextFieldItem: UIBarButtonItem = UIBarButtonItem.init(customView: commentTextView)
        let flexItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        let commentButton: UIBarButtonItem = UIBarButtonItem(title: "Post", style: UIBarButtonItemStyle.Plain, target: self, action: "postComment:")
        let barItems: [UIBarButtonItem] = NSArray(objects: commentTextFieldItem, flexItem, commentButton) as! [UIBarButtonItem]
        
        toolbar.setItems(barItems, animated: true)
    }
    
     func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        print("hey")
        self.commentTableView.frame = CGRectMake(self.commentTableView.frame.origin.x, self.commentTableView.frame.origin.y, self.commentTableView.frame.size.width, self.commentTableView.frame.size.height - 190)
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setLikeButtonStateOnLoad() {
        if self.isLiked == true {
            self.likeButton.setImage(UIImage(named: "like_filled.png"), forState: UIControlState.Normal)
        }
        else {
            self.likeButton.setImage(UIImage(named: "like.png"), forState: UIControlState.Normal)
        }
    }
    
    func removeLikeButtonForMyPosts() {
        if(originalPosterId == app.deviceId) {
            likeButton.enabled = false
        }
        else {
            likeButton.enabled = true
        }
    }
    
    func likePost(sender: UIButton) {
        
        let postAndUserId = [
            "postId": postId,
            "userId": app.deviceId
        ]
        
        if (sender.imageView?.image == UIImage(named: "like.png")) {
            sender.setImage(UIImage(named: "like_filled.png"), forState: UIControlState.Normal)
            
            socket.emit("likePost", postAndUserId)
            
            postLikes? += 1
            likesLabel?.text = String(postLikes)
        }
            
        else if (sender.imageView?.image == UIImage(named: "like_filled.png")) {
            sender.setImage(UIImage(named: "like.png"), forState: UIControlState.Normal)
            
            socket.emit("unlikePost", postAndUserId)
            
            postLikes? -= 1
            likesLabel?.text = String(postLikes)
        }
        
    }
    
    func likeComment(sender:UIButton) {
        let buttonPosition: CGPoint = sender.convertPoint(CGPointZero, toView: self.commentTableView)
        let indexPath: NSIndexPath = self.commentTableView.indexPathForRowAtPoint(buttonPosition)!
        let cell: PostCommentCell = self.commentTableView.cellForRowAtIndexPath(indexPath) as! PostCommentCell
        
        let commentId: String = self.comments[indexPath.row].valueForKey("_id") as! String
        
        print(commentId)
        
        let postIdAndUserId = [
            "postId": postId,
            "commentId": commentId,
            "userId": app.deviceId
        ]
        
        if (sender.imageView?.image == UIImage(named: "like.png")) {
            sender.setImage(UIImage(named: "like_filled.png"), forState: UIControlState.Normal)
            
            socket.emit("likeComment", postIdAndUserId)
            
            cell.likesInt? += 1
            cell.numOfLikes?.text = String(cell.likesInt)
        }
            
        else if (sender.imageView?.image == UIImage(named: "like_filled.png")) {
            sender.setImage(UIImage(named: "like.png"), forState: UIControlState.Normal)
            
            socket.emit("unlikeComment", postIdAndUserId)
            
            cell.likesInt? -= 1
            cell.numOfLikes?.text = String(cell.likesInt)
        }
    }
    
    @IBAction func postComment(button: UIBarButtonItem) {
        
        let commentJSON = [
            "postId": postId,
            "userId": deviceId,
            "content": commentTextView.text,
        ]
        
        let rawString: NSString = commentTextView.text
        let whitespace: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let trimmed: NSString = rawString.stringByTrimmingCharactersInSet(whitespace)
        
        if(trimmed.length == 0) {
            // Text was empty or only whitespace.

        }
        else {
            socket.emit("createComment", commentJSON)
            commentTextView.text = ""
        }
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        socket.emit("loadComments", self.postId)
        refreshControl.endRefreshing()
    }
    
    func checkIfMyComment(cell: PostCommentCell, item: AnyObject) {
        let commenterId: String = item.valueForKey("userId") as! String
        
        if(commenterId == originalPosterId) {
            cell.postCommentsContent.textColor = UIColor.redColor()
        }
        
        if(commenterId == app.deviceId) {
            cell.likeButton.enabled = false
        }
        else {
            cell.likeButton.enabled = true
        }
        
    }
    
    func checkIfIveLikedComment(cell: PostCommentCell, item: AnyObject) {
        let likersPerComment: NSArray = item.valueForKey("likers") as! NSArray
        
        if (likersPerComment.containsObject(app.deviceId)) {
            cell.likeButton.setImage(UIImage(named: "like_filled.png"), forState: UIControlState.Normal)
        }
        else {
            cell.likeButton.setImage(UIImage(named: "like.png"), forState: UIControlState.Normal)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return postCellAtIndexPath(indexPath)
    }
    
    func postCellAtIndexPath(indexPath: NSIndexPath) -> PostCommentCell {
        let cell:PostCommentCell = self.commentTableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PostCommentCell
        
        self.configureBasicCell(cell, atIndexPath: indexPath)
        
        cell.likeButton.addTarget(self, action: "likeComment:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
        
    }
    
    func configureBasicCell(cell: PostCommentCell, atIndexPath indexPath: NSIndexPath) {
        let comment: AnyObject = self.comments[indexPath.row]
        self.setPostContentForCell(cell, item: comment)
        self.checkIfMyComment(cell, item: comment)
        self.checkIfIveLikedComment(cell, item: comment)
    }
    
    func setPostContentForCell(cell: PostCommentCell, item: AnyObject) {
        let content: String = item.valueForKey("content") as! String
        cell.postCommentsContent?.text = content
        
        cell.likesInt = item.valueForKey("likes") as! Int
        
        cell.numOfLikes?.text = String(cell.likesInt)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print("You selected cell #\(indexPath.row)!")
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return heightForBasicCellAtIndexPath(indexPath)
    }
    
    func heightForBasicCellAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        var sizingCell: PostCommentCell!
        var token: dispatch_once_t = 0
        
        dispatch_once(&token, { () -> Void in
            sizingCell = self.commentTableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as! PostCommentCell
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
