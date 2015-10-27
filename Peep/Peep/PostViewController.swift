//
//  PostViewController.swift
//  Peep
//
//  Created by Raymond_Dev on 8/29/15.
//  Copyright (c) 2015 Rayngel. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift

class PostViewController: UIViewController, UITextViewDelegate {

    var app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var cancelPostButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    
    var maxCharacterCount: Int! = 180
    
    var socket: SocketIOClient!
    
    var deviceId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.socket = app.socket
        self.deviceId = app.deviceId
        
        
        cancelPostButton.target = self
        cancelPostButton.action = "cancelPost:"
        
        postButton.target = self
        postButton.action = "post:"
        
        textView.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.textView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelPost(button:UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    func textViewDidChange(textView: UITextView) {
        let characterCount = self.maxCharacterCount - textView.text.characters.count
        print(characterCount)
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if textView.text.characters.count - range.length + text.characters.count > self.maxCharacterCount {
            return false
        }
        return true
    }
    
    @IBAction func post(button: UIBarButtonItem) {
        let postJSON = [
            "userId": deviceId,
            "content": textView.text,
            "hashtags": findHashtags()
        ]
        socket.emit("createPost", postJSON)
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    // find different way to get hashtags from textView similar to ActiveLabel 
    func findHashtags() -> NSMutableArray {
        let hashtagArray: NSMutableArray! = []
        var regex: NSRegularExpression = NSRegularExpression()
        
        let contentString: String = (textView.text)!
        
        let string: NSString = contentString as NSString
        
        do {
            regex = try NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpressionOptions.CaseInsensitive)
        }
        catch {}
        
        let matches: NSArray = regex.matchesInString(contentString, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, contentString.characters.count))
        
        for match: NSTextCheckingResult in matches as! [NSTextCheckingResult] {
            let wordRange: NSRange = match.rangeAtIndex(1)
            
            var stringToSave: String = string.substringWithRange(wordRange)
            stringToSave = stringToSave.lowercaseString
            
            hashtagArray.addObject(stringToSave)
        }
        return hashtagArray
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
