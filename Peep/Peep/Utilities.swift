//
//  Utilities.swift
//  Peep
//
//  Created by Raymond_Dev on 10/19/15.
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
    
    func displayMessageForLoadingContent(tableView: UITableView) ->UILabel {
        let messageLabel = UILabel(frame: CGRectMake(0, 0, tableView.frame.width, tableView.frame.height))
        messageLabel.text = "Loading"
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel
        
        return messageLabel
    }
    
    func displayMessageForNoContent(tableView: UITableView) ->UILabel {
        let messageLabel = UILabel(frame: CGRectMake(0, 0, tableView.frame.width, tableView.frame.height))
        messageLabel.text = "Nothing :("
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel
        
        return messageLabel
    }
    
    
    func startNetworkIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

    }
    
    func stopNetworkIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

    }


}
