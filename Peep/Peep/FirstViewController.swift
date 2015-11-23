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
    
    //var deviceId: String!
   
    var posts: NSArray! = []
    
    var userId: NSString!

    //let socket = SocketIOClient(socketURL: "192.168.1.4:8000")
    let socket = SocketIOClient(socketURL: "http://ec2-52-32-153-117.us-west-2.compute.amazonaws.com:8080")
    
    var hashtagToSend: String!
    
    var scrolling: Bool! = false
    
    var labelForNoContent: UILabel!
    var labelForLoadingContent: UILabel!
    var loading: Bool = false
    
    func socketHandlers() {
        socket.onAny {_ in
            Utilities().startNetworkIndicator()
            self.loading = true
        }
        socket.on("connect") {data, ack in
            print("connected to ec2:8080")
        }
        
        socket.on("loadPosts") {data, ack in
            self.posts = data?[0] as? NSArray
            
            self.tableView.reloadData()
            
            if(self.posts.count == 0) {
                self.tableView.backgroundView = self.labelForNoContent
            }
            
            self.loading = false
            Utilities().stopNetworkIndicator()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelForLoadingContent = Utilities().displayMessageForLoadingContent(self.view)
        labelForNoContent = Utilities().displayMessageForNoContent(self.view)
        
//        labelForNoContent.hidden = false
//        labelForLoadingContent.hidden = false
        
        tableView.backgroundView = labelForLoadingContent
        //tableView.backgroundView = labelForNoContent
        
        self.tabBarController!.tabBar.layer.borderColor = UIColor.redColor().CGColor

        
//        let tabBarController = self.tabBarController! as UITabBarController
//        let tabBar = tabBarController.tabBar
//        
//        for item in tabBar.items! as [UITabBarItem] {
//            item.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.redColor()], forState: UIControlState.Normal)
//        }
        
        // Do any additional setup after loading the view, typically from a nib.
        app.socket = self.socket
        
        if (NSUserDefaults.standardUserDefaults().stringForKey("userId") == nil) {
            let genUserId = Utilities().generateUserId(32)
            
            NSUserDefaults.standardUserDefaults().setObject(genUserId, forKey: "userId")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            app.userId = genUserId
        }
        
        else {
            self.userId = NSUserDefaults.standardUserDefaults().stringForKey("userId")
            app.userId = self.userId
        }
        
//        self.deviceId = UIDevice.currentDevice().identifierForVendor!.UUIDString
//        app.deviceId = self.deviceId
        
        //self.tableView.tableHeaderView = UIView()
        self.tableView.tableFooterView = UIView()
        self.tableView.canCancelContentTouches = true

        socketHandlers()
        self.socket.connect()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        activityIndicator()
        
    }
    
    var indicator = UIActivityIndicatorView()
    
    func activityIndicator(){
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = self.view.center
        self.tableView.addSubview(indicator)
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

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
            let cell: PostCellTableViewCell = self.tableView.cellForRowAtIndexPath(indexPath) as! PostCellTableViewCell
            
            let destinationViewController: PostDetailAndCommentViewController = segue.destinationViewController as! PostDetailAndCommentViewController
            
            //self.tabBarController?.tabBar.hidden = true
            //destinationViewController.hidesBottomBarWhenPushed = true
            
            destinationViewController.detailContent = posts[indexPath.row].valueForKey("content") as! String
            destinationViewController.postId = posts[indexPath.row].valueForKey("_id") as! String
            destinationViewController.originalPosterId = posts[indexPath.row].valueForKey("userId") as! String
            destinationViewController.postLikes = cell.likesInt
            destinationViewController.isLiked = cell.isLiked
            destinationViewController.timeCreated = cell.timeLabel.text
        }
        else if(segue.identifier == "loadHashtags") {
            let destinationViewController: MyPostsAndCommentsViewController = segue.destinationViewController as! MyPostsAndCommentsViewController
            destinationViewController.serverRequest = "loadPostsWithHashtag"
            destinationViewController.hashtagToSend = self.hashtagToSend
            destinationViewController.navigationTitle = "#\(hashtagToSend.uppercaseString)"
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
    
    func setupGestureRecognizerForContentLabel(cell: PostCellTableViewCell) {
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "labelTapped:")
        
        cell.postContent.userInteractionEnabled = true
        cell.postContent.addGestureRecognizer(gesture)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        print("scroll")
        self.scrolling = true
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("end scroll")
        self.scrolling = false
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.posts.count > 0) {
            labelForNoContent.hidden = true
            labelForLoadingContent.hidden = true
            return self.posts.count
        }
        else {
            //self.tableView.backgroundView = labelForNoContent
            //labelForNoContent.hidden = false
            print("empty")
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return postCellAtIndexPath(indexPath)
    }
    
    func postCellAtIndexPath(indexPath: NSIndexPath) -> PostCellTableViewCell {
        let cell:PostCellTableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PostCellTableViewCell
                    
        self.configureBasicCell(cell, atIndexPath: indexPath)
        
        cell.likeButton.addTarget(self, action: "likePost:", forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
        
    }
    
    func configureBasicCell(cell: PostCellTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let item: AnyObject = self.posts[indexPath.row]
        self.setPostContentForCell(cell, item: item)
        self.checkIfIveLikedPost(cell, item: item)
        self.removeLikeButtonForMyPosts(cell, item: item)
        
        cell.postContent.handleHashtagTap {
            if (self.scrolling == false) {
                self.hashtagToSend = $0.lowercaseString
                //self.tabBarController?.tabBar.hidden = true
                self.performSegueWithIdentifier("loadHashtags", sender: self)
            }
        }
        
    }
    
    func setPostContentForCell(cell: PostCellTableViewCell, item: AnyObject) {
        let timeCreated = item.valueForKey("timeCreated") as! String!
        
        let numOfComments = item.valueForKey("comments")?.count
        cell.numOfComments.text = Utilities().countComments(numOfComments!)
        
        let content: String = item.valueForKey("content") as! String
        cell.likesInt = item.valueForKey("likes") as! Int
        
        cell.postContent?.text = content
        cell.numOfLikes?.text = String(cell.likesInt)
        cell.timeLabel?.text = Utilities().stringForTimeIntervalSinceCreated(timeCreated) as String
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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

