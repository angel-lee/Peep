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
    
    override func viewDidAppear(animated: Bool) {
        //self.showTabBar(self.tabBarController!)
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        socket.emit("reloadPosts")
        refreshControl.endRefreshing()
    }
    
//    - (void)hideTabBar:(UITabBarController *) tabbarcontroller
//    {
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.5];
//    
//    for(UIView *view in tabbarcontroller.view.subviews)
//    {
//    if([view isKindOfClass:[UITabBar class]])
//    {
//    [view setFrame:CGRectMake(view.frame.origin.x, 480, view.frame.size.width, view.frame.size.height)];
//    }
//    else
//    {
//    [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 480)];
//    }
//    }
//    
//    [UIView commitAnimations];
//    }
    func hideTabBar(tabBarController: UITabBarController) {
        UIView.beginAnimations("", context: nil)
        UIView.setAnimationDuration(0.5)
        
        for view: UIView in tabBarController.view.subviews {
            if (view.isKindOfClass(UITabBar)) {
                view.hidden = true
            }
        }
        
        UIView.commitAnimations()
    }
    
    func showTabBar(tabBarController: UITabBarController) {
        UIView.beginAnimations("", context: nil)
        UIView.setAnimationDuration(0.5)
        
        for view: UIView in tabBarController.view.subviews {
            if (view.isKindOfClass(UITabBar)) {
                view.hidden = false
            }
        }
        
        UIView.commitAnimations()
    }
    func sendDataToA(indexPath: NSIndexPath, likesInt: Int, likeButton: UIButton) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showDetailPostAndComments") {
            let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow!
            let cell: PostCellTableViewCell = self.tableView.cellForRowAtIndexPath(indexPath) as! PostCellTableViewCell
            
            let destinationViewController: PostDetailAndCommentViewController = segue.destinationViewController as! PostDetailAndCommentViewController
            
            //self.hideTabBar(self.tabBarController!)
            
            self.tabBarController?.tabBar.hidden = true
            
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
        else if(segue.identifier == "loadHashtags") {
            let destinationViewController: MyPostsAndCommentsViewController = segue.destinationViewController as! MyPostsAndCommentsViewController
            destinationViewController.serverRequest = "loadPostsWithHashtag"
            destinationViewController.hashtagToSend = self.hashtagToSend
            destinationViewController.navigationTitle = "#\(hashtagToSend)"
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
    
    func setupGestureRecognizerForContentLabel(cell: PostCellTableViewCell) {
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "labelTapped:")
        
        cell.postContent.userInteractionEnabled = true
        cell.postContent.addGestureRecognizer(gesture)
    }
    
    func labelTapped(sender: AnyObject) {
        print("tapped label")
        
    }
    
//    func findHashtags(cell: PostCellTableViewCell, item: AnyObject) {
//        var regex: NSRegularExpression = NSRegularExpression()
//                
//        let cellContentString: String = (cell.postContent?.text)!
//        
//        let string = NSMutableAttributedString(string: cell.postContent.text!)
//        
//        do {
//            regex = try NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpressionOptions.CaseInsensitive)
//        }
//        catch {}
//        
//        let matches: NSArray = regex.matchesInString(cellContentString, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, cellContentString.characters.count))
//        
//        for match: NSTextCheckingResult in matches as! [NSTextCheckingResult] {
//            let wordRange: NSRange = match.rangeAtIndex(0)
//            
//            string.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: wordRange)
//    }
//        
//        cell.postContent?.attributedText = string
//    }
    
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
            self.tabBarController?.tabBar.hidden = true
            self.performSegueWithIdentifier("loadHashtags", sender: self)
        }
    }
    
    func setPostContentForCell(cell: PostCellTableViewCell, item: AnyObject) {
        let timeCreated = item.valueForKey("timeCreated") as! String!

        //print(timeCreated!)
        let dateFormatter = NSDateFormatter()
        //[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        dateFormatter.dateFormat = "yyyy-MM-ddEHH:mm:ss.SSS'Z'"
        let date = dateFormatter.dateFromString(timeCreated)
//        let calendar = NSCalendar.currentCalendar()
//        let comp = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date!)
//        let hour = comp.hour
//        let minute = comp.minute
//        
//        let currentDate = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: NSDate())
//
//        
//        let timeInterval = (currentDate.minute - comp.minute)
        //print(minute)
        //print(date)
        let numOfComments = item.valueForKey("comments")?.count
        cell.numOfComments.text = Utilities().countComments(numOfComments!)
        
        let content: String = item.valueForKey("content") as! String
        cell.likesInt = item.valueForKey("likes") as! Int
        
        cell.postContent?.text = content
        cell.numOfLikes?.text = String(cell.likesInt)
        //cell.timeLabel?.text = Utilities().stringForTimeIntervalSinceCreated(date!) as String
        //cell.timeLabel?.text = String(date!)
        //print(date!.descriptionWithLocale(NSLocale.currentLocale()))

    }
//
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        //print("You selected cell #\(indexPath.row)!")d
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let destinationViewController: PostDetailAndCommentViewController = storyboard.instantiateViewControllerWithIdentifier("postDetails") as! PostDetailAndCommentViewController
//                
//        destinationViewController.detailContent = posts[indexPath.row].valueForKey("content") as! String
//        //destinationViewController.comments = posts[indexPath.row].valueForKey("comments") as! NSArray
//        destinationViewController.postId = posts[indexPath.row].valueForKey("_id") as! String
//        destinationViewController.originalPosterId = posts[indexPath.row].valueForKey("userId") as! String
//        destinationViewController.postLikes = posts[indexPath.row].valueForKey("likes") as! Int
//        
//        self.navigationController?.pushViewController(destinationViewController, animated: true)
//    }
    
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

