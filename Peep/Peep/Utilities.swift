//
//  Utilities.swift
//  Peep
//
//  Created by Raymond Clark & Angel Lee on 10/19/15.
//  Copyright © 2015 Rayngel. All rights reserved.
//

import UIKit

class Utilities: NSObject {
    
    func stringForTimeIntervalSinceCreated(timeCreated: String) -> NSString {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-ddEHH:mm:ss.SSS'Z'"
        
        let date = dateFormatter.dateFromString(timeCreated)
        
        let timeScale: NSDictionary = [
            "s": 1,
            "m": 60,
            "h": 3600,
            "d": 86400,
            "w": 605800,
            "mo": 2629743,
            "y": 31556926
        ]
        
        var scale: NSString!
        
        var timeAgo = 0 - Int(date!.timeIntervalSinceNow)
        
        if (timeAgo < 60) {
            scale = "s";
        } else if (timeAgo < 3600) {
            scale = "m";
        } else if (timeAgo < 86400) {
            scale = "h";
        } else if (timeAgo < 605800) {
            scale = "d";
        } else if (timeAgo < 2629743) {
            scale = "w";
        } else if (timeAgo < 31556926) {
            scale = "mo";
        } else {
            scale = "y";
        }
        
        
        timeAgo = timeAgo / timeScale.objectForKey(scale)!.integerValue
        
        return (scale == "s") ? "now" : "\(timeAgo)\(scale)"
        
    }
    


    func countComments(count: Int) -> String {
        if (count == 1) {
            return "\(count) COMMENT"
        }
        else {
            return "\(count) COMMENTS"
        }
    }
    
    func generateUserId(len: Int) -> NSString {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let userId : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            userId.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return userId
    }
    
    func displayMessageForLoadingContent(theView: UIView) ->UILabel {
        let messageLabel = UILabel(frame: CGRectMake(0, 0, theView.bounds.size.width, theView.bounds.size.height))
        messageLabel.text = "Loading :)"
        messageLabel.font = UIFont(name: "Helvetica-Bold", size: 18)!
        messageLabel.textColor = UIColor.lightGrayColor()
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.sizeToFit()
        
        //tableView.backgroundView = messageLabel
        
        return messageLabel
    }
    
    func displayMessageForNoContent(theView: UIView) ->UILabel {
        let messageLabel = UILabel(frame: CGRectMake(0, 0, theView.bounds.size.width, theView.bounds.size.height))
        messageLabel.text = "Nothing :("
        messageLabel.font = UIFont(name: "Helvetica-Bold", size: 18)!
        messageLabel.textColor = UIColor.lightGrayColor()
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.sizeToFit()
        
        //tableView.backgroundView = messageLabel
        
        return messageLabel
    }
    
    
    func startNetworkIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

    }
    
    func stopNetworkIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

    }
    
    func actvityIndicatorView(view: UIView) -> UIActivityIndicatorView {
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(view.frame.width/2, view.frame.height/2, 100, 100))
        
        view.addSubview(activityIndicator)
        
        return activityIndicator
    }

}
