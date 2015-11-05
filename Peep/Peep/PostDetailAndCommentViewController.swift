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

class PostDetailAndCommentViewController: UITableViewController, UITextViewDelegate {

    var app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var socket: SocketIOClient!
    
    var hashtagToSend: String!
    
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var detailContentLabel: ActiveLabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var postCommentButton: UIBarButtonItem!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    
    //@IBOutlet weak var toolbar: UIToolbar!
    
    var detailContent: String!
    
    var comments: NSArray! = []
    
    let cellIdentifier: String = "commentContentCell"

    var userId: NSString!
    
    var postId: String!
    
    var originalPosterId: String!
    
    var postLikes: Int!
    
    var thePost: AnyObject!
    
    var postLikers: NSArray! = []
    
    var buttonString: String!
    
    var isLiked: Bool!
    
    var commentTextView: UITextView!

    var kbHeight: CGFloat!
    
    var toolbar: UIToolbar!
    
    func socketHandlers() {
        socket.on("loadComments") {data, ack in
            
            self.comments = data?[0] as? NSArray
            
            self.commentTableView.reloadData()
        }
        
        socket.on("commentSaved") {data, ack in
            self.comments = data?[0] as? NSArray
            
            self.commentTableView.reloadData()
            
            if(self.commentTableView.numberOfRowsInSection(0) == 0) {
                
            }
            else {
                let indexPath = self.commentTableView.numberOfRowsInSection(0) - 1
                self.commentTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: indexPath, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            }
        }
        
        socket.on("getThePost") {data, ack in

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "Post"
        
        detailContentLabel.numberOfLines = 0
        detailContentLabel.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
        
        likeButton.addTarget(self, action: "likePost:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.userId = app.userId
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
    
    func animateTextField(up: Bool) {
        let movement = (up ? -kbHeight : kbHeight)
        print(movement)
        
        UIView.animateWithDuration(0.3, animations: {
            self.navigationController!.toolbar.frame.origin.y += movement
            self.commentTableView.frame = CGRectMake(self.commentTableView.frame.origin.x, self.commentTableView.frame.origin.y, self.commentTableView.frame.size.width, self.commentTableView.frame.size.height + movement)
            if(self.commentTableView.numberOfRowsInSection(0) == 0) {
                
            }
            else {
                let indexPath = self.commentTableView.numberOfRowsInSection(0) - 1
                self.commentTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: indexPath, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            }
        })
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height
                self.animateTextField(true)
            }
            
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.animateTextField(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(false, animated: true)

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        print("did a")
        commentTextView = UITextView(frame: CGRectMake(0,0,self.view.frame.width - (self.view.frame.width/5),32))
        commentTextView.delegate = self
        commentTextView.keyboardType = .Twitter
        commentTextView.font = UIFont(name: "Helvetica Neue", size: 15)
        commentTextView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.borderColor = UIColor.grayColor().CGColor
        commentTextView.layer.cornerRadius = 5
        
        let commentTextFieldItem: UIBarButtonItem = UIBarButtonItem.init(customView: commentTextView)
        let flexItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        let commentButton: UIBarButtonItem = UIBarButtonItem(title: "Post", style: UIBarButtonItemStyle.Plain, target: self, action: "postComment:")
        let barItems: [UIBarButtonItem] = NSArray(objects: commentTextFieldItem, flexItem, commentButton) as! [UIBarButtonItem]
        
        //toolbar.setItems(barItems, animated: true)
        //self.navigationController?.toolbar.frame.origin.y = 100
        self.setToolbarItems(barItems, animated: true)
    }
    
    func contentSizeRectForTextView(textView: UITextView) -> CGRect {
        textView.layoutManager.ensureLayoutForTextContainer(textView.textContainer)
        let textBounds: CGRect = textView.layoutManager.usedRectForTextContainer(textView.textContainer)
        let width: CGFloat = CGFloat(ceil(textBounds.size.width + textView.textContainerInset.left + textView.textContainerInset.right))
        let height: CGFloat = CGFloat(ceil(textBounds.size.height + textView.textContainerInset.top + textView.textContainerInset.bottom))
        return CGRectMake(0, 0, width, height)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //print("did d")

        NSNotificationCenter.defaultCenter().removeObserver(self)

        
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
     func textViewShouldBeginEditing(textView: UITextView) -> Bool {        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        //contentSizeRectForTextView(self.commentTextView)
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
        if(originalPosterId == app.userId) {
            likeButton.enabled = false
        }
        else {
            likeButton.enabled = true
        }
    }
    
    func likePost(sender: UIButton) {
        
        let postAndUserId = [
            "postId": postId,
            "userId": app.userId
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
            "userId": app.userId
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
            "userId": userId,
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
        
        if(commenterId == app.userId) {
            cell.likeButton.enabled = false
        }
        else {
            cell.likeButton.enabled = true
        }
        
    }
    
    func checkIfIveLikedComment(cell: PostCommentCell, item: AnyObject) {
        let likersPerComment: NSArray = item.valueForKey("likers") as! NSArray
        
        if (likersPerComment.containsObject(app.userId)) {
            cell.likeButton.setImage(UIImage(named: "like_filled.png"), forState: UIControlState.Normal)
        }
        else {
            cell.likeButton.setImage(UIImage(named: "like.png"), forState: UIControlState.Normal)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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
