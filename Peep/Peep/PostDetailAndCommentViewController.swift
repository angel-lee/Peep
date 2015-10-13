//
//  PostDetailAndCommentViewController.swift
//  Peep
//
//  Created by Raymond_Dev on 9/20/15.
//  Copyright © 2015 Rayngel. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift

class PostDetailAndCommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var socket: SocketIOClient!

    
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var detailContentLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var postCommentButton: UIBarButtonItem!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    
    var detailContent: String!
    
    var comments: NSArray! = []
    
    //var testArray: NSArray! = ["comment1", "comment2"]
    
    let cellIdentifier: String = "commentContentCell"

    var deviceId: String!
    
    var postId: String!
    
    var originalPosterId: String!
    
    var postLikes: Int!
    
    var thePost: AnyObject!
    
    var postLikers: NSArray! = []

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
            self.thePost = data?[0]
            //print(self.thePost.valueForKey("content"))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //print(postLikes)
        
        //print(postLikes)
        
        //setContentForOriginalPost()
        
        likeButton.addTarget(self, action: "likePost:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.deviceId = app.deviceId
        self.socket = app.socket
        
        socketHandlers()
        
        socket.emit("loadComments", self.postId)
        socket.emit("getThePost", self.postId)
        
        
        detailContentLabel.text = detailContent
        likesLabel.text = String(postLikes)
        
        postCommentButton.target = self
        postCommentButton.action = "postComment:"
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        commentTableView.addSubview(refreshControl)
        
        //checkIfLikedOriginalPost()
        //setContentForOriginalPost()
        
        findHashtags()
        removeLikeButtonForMyPosts()
        
        //print(thePost)
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
    
    func removeLikeButtonForMyPosts() {
        if(originalPosterId == app.deviceId) {
            likeButton.enabled = false
            likeButton.hidden = true
        }
        else {
            likeButton.enabled = true
            likeButton.hidden = false
        }
    }

    func findHashtags() {
        var regex: NSRegularExpression = NSRegularExpression()
        
        
        let contentString: String = detailContentLabel.text!
        
        let string = NSMutableAttributedString(string: detailContentLabel.text!)
        
        do {
            regex = try NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpressionOptions.CaseInsensitive)
        }
        catch {}
        
        let matches: NSArray = regex.matchesInString(contentString, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, contentString.characters.count))
        
        for match: NSTextCheckingResult in matches as! [NSTextCheckingResult] {
            let wordRange: NSRange = match.rangeAtIndex(0)
            
            string.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: wordRange)
            //string.addAttribute(NSLinkAttributeName, value: "http://www.google.com", range: wordRange)
        }
        
        detailContentLabel.attributedText = string
    }
    
    func setContentForOriginalPost() {
        //print(self.thePost)
    }
    
    func checkIfLikedOriginalPost() {
        //print(thePost)
    }
    
    func likePost(sender: UIButton) {
        
        let postAndUserId = [
            "postId": postId,
            "userId": app.deviceId
        ]
        
        if (sender.titleLabel?.text == "like") {
            sender.setTitle("unlike", forState: UIControlState.Normal)
            
            socket.emit("likePost", postAndUserId)
            
            postLikes? += 1
            likesLabel?.text = String(postLikes)
        }
            
        else if (sender.titleLabel?.text == "unlike") {
            sender.setTitle("like", forState: UIControlState.Normal)
            
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
        
        if (sender.titleLabel?.text == "like") {
            sender.setTitle("unlike", forState: UIControlState.Normal)
            
            socket.emit("likeComment", postIdAndUserId)
            
            cell.likesInt? += 1
            cell.numOfLikes?.text = String(cell.likesInt)
        }
            
        else if (sender.titleLabel?.text == "unlike") {
            sender.setTitle("like", forState: UIControlState.Normal)
            
            socket.emit("unlikeComment", postIdAndUserId)
            
            cell.likesInt? -= 1
            cell.numOfLikes?.text = String(cell.likesInt)
        }
    }
    
    @IBAction func postComment(button: UIBarButtonItem) {

        let commentJSON = [
            "postId": postId,
            "userId": deviceId,
            "content": commentTextField.text,
        ]
        
        socket.emit("createComment", commentJSON)
        commentTextField.text = ""
        //socket.emit("loadComments", self.postId)
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
            cell.likeButton.hidden = true
        }
        else {
            cell.likeButton.enabled = true
            cell.likeButton.hidden = false
        }
        
    }
    
    func checkIfIveLikedComment(cell: PostCommentCell, item: AnyObject) {
        let likersPerComment: NSArray = item.valueForKey("likers") as! NSArray
        
        if (likersPerComment.containsObject(app.deviceId)) {
            cell.likeButton.setTitle("unlike", forState: UIControlState.Normal)
        }
        else {
            cell.likeButton.setTitle("like", forState: UIControlState.Normal)
        }
    }
    
    func findHashtags(cell: PostCommentCell, item: AnyObject) {
        var regex: NSRegularExpression = NSRegularExpression()
                
        let cellContentString: String = (cell.postCommentsContent?.text)!
        
        let string = NSMutableAttributedString(string: cell.postCommentsContent.text!)
        
        do {
            regex = try NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpressionOptions.CaseInsensitive)
        }
        catch {}
        
        let matches: NSArray = regex.matchesInString(cellContentString, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, cellContentString.characters.count))
        
        for match: NSTextCheckingResult in matches as! [NSTextCheckingResult] {
            let wordRange: NSRange = match.rangeAtIndex(0)
            
            string.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: wordRange)
            //string.addAttribute(NSLinkAttributeName, value: "http://www.google.com", range: wordRange)
        }
        
        cell.postCommentsContent?.attributedText = string
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(self.comments.count)
        return self.comments.count
        //return self.testArray.count
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
        self.findHashtags(cell, item: comment)
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
