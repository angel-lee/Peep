//
//  Utilities.swift
//  Peep
//
//  Created by Raymond_Dev on 10/19/15.
//  Copyright © 2015 Rayngel. All rights reserved.
//

import UIKit

class Utilities: NSObject {
    
    func stringForTimeIntervalSinceCreated(dateTime: NSDate) -> NSString {
        let timeScale: NSDictionary = [
            "SECOND": 1,
            "MINUTE": 60,
            "HOUR": 3600,
            "DAY": 86400,
            "WEEK": 605800,
            "MONTH": 2629743,
            "YEAR": 31556926
        ]
        
        var scale: NSString!
        
        let currentDate = NSDate()
        print(currentDate)
        
        var timeAgo = 0 - Int(dateTime.timeIntervalSinceNow)
        
        if (timeAgo < 60) {
            scale = "SECOND";
        } else if (timeAgo < 3600) {
            scale = "MINUTE";
        } else if (timeAgo < 86400) {
            scale = "HOUR";
        } else if (timeAgo < 605800) {
            scale = "DAY";
        } else if (timeAgo < 2629743) {
            scale = "WEEK";
        } else if (timeAgo < 31556926) {
            scale = "MONTH";
        } else {
            scale = "YEAR";
        }
        
        
        timeAgo = timeAgo / timeScale.objectForKey(scale)!.integerValue
        
        var s: String = ""
        if(timeAgo > 1) {
            s = "S"
        }
        
        return "\(timeAgo) \(scale)\(s)"
        
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


}
