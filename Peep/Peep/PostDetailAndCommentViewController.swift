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
    
    var detailContent: String!
    
    var comments: NSArray! = []
    
    //var testArray: NSArray! = ["comment1", "comment2"]
    
    let cellIdentifier: String = "commentContentCell"

    var deviceId: String!
    
    var postId: String!
    
    func socketHandlers() {
        socket.on("loadComments") {data, ack in
            
            self.comments = data?[0] as? NSArray
                        
            self.commentTableView.reloadData()
        }
        
        socket.on("commentSaved") {data, ack in
            self.comments = data?[0] as? NSArray
            
            self.commentTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.deviceId = app.deviceId
        self.socket = app.socket
        
        socket.emit("loadComments", self.postId)
        
        detailContentLabel.text = detailContent
        
        socketHandlers()
        
        postCommentButton.target = self
        postCommentButton.action = "postComment:"
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        commentTableView.addSubview(refreshControl)
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
    
    @IBAction func postComment(button: UIBarButtonItem) {
        let commentJSON = [
            "postId": postId,
            "userId": deviceId,
            "content": commentTextField.text
        ]
        socket.emit("createComment", commentJSON)
        commentTextField.text = ""
        //socket.emit("loadComments", self.postId)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        socket.emit("loadComments", self.postId)
        refreshControl.endRefreshing()
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
        
        return cell
        
    }
    
    func configureBasicCell(cell: PostCommentCell, atIndexPath indexPath: NSIndexPath) {
        let comment: AnyObject = self.comments[indexPath.row]
        self.setPostContentForCell(cell, item: comment)
    }
    
    func setPostContentForCell(cell: PostCommentCell, item: AnyObject) {
        let content: String = item.valueForKey("content") as! String
        cell.postCommentsContent?.text = content
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
