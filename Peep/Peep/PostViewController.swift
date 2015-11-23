//
//  PostViewController.swift
//  Peep
//
//  Created by Raymond_Dev on 8/29/15.
//  Copyright (c) 2015 Rayngel. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift
import ActiveLabel


class PostViewController: UIViewController, UITextViewDelegate {

    var app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var cancelPostButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    //@IBOutlet weak var characterCountLabel: UILabel!
    
    var maxCharacterCount: Int! = 180
    
    var characterCount: Int! = 180
    
    var currentCharacterCount: Int! = 0
    
    var socket: SocketIOClient!
    
    var userId: NSString!
    
    var kbHeight: CGFloat!
    
    var kbLastHeight: CGFloat!
    
    var kbMoveAmount: CGFloat!
    
    var characterCountLabel: UILabel!
    
    var toolbar: UIToolbar!
    
    var inputTextLabel: ActiveLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.socket = app.socket
        self.userId = app.userId
        
        
        cancelPostButton.target = self
        cancelPostButton.action = "cancelPost:"
        
        postButton.target = self
        postButton.action = "post:"
        
        self.textView.keyboardType = .Twitter
        self.textView.becomeFirstResponder()
        
        addToolbarWithCharacterCount()
    }
    
    func addToolbarWithCharacterCount() {
        self.toolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 44))
//        [self.toolbar setBackgroundImage:[UIImage new]
//            forToolbarPosition:UIToolbarPositionAny
//            barMetrics:UIBarMetricsDefault];
        self.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: UIBarMetrics.Default)
        self.toolbar.backgroundColor = UIColor.clearColor()
        self.toolbar.clipsToBounds = true
        self.toolbar.sizeToFit()
        
        characterCountLabel = UILabel(frame: CGRectMake(0, 0, 40, 40))
        characterCountLabel.textColor = UIColor(red: 69/255, green: 173/255, blue: 255/255, alpha: 1)
        characterCountLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        //characterCountLabel.backgroundColor = UIColor(red: 69/255, green: 173/255, blue: 255/255, alpha: 1)
        characterCountLabel.text = String(self.maxCharacterCount)
        
        let flexItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        let characterLabel: UIBarButtonItem = UIBarButtonItem.init(customView: self.characterCountLabel)
        
        let barItems: [UIBarButtonItem] = NSArray(objects: flexItem, characterLabel) as! [UIBarButtonItem]
        
        self.toolbar.setItems(barItems, animated: true)
        
        //self.textView.addSubview(self.toolbar)
        self.textView.inputAccessoryView = self.toolbar
    }
    
    
    override func viewWillAppear(animated: Bool) {
        kbLastHeight = 0

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.textView.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateTextLabel(up: Bool) {
        let movement = (up ? -kbMoveAmount : kbMoveAmount)
        print(movement)
        
        UIView.animateWithDuration(0.3, animations: {
            //self.toolbar.frame.origin.y += movement
        })
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //print("keyboard show")
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height
                kbMoveAmount = kbHeight - kbLastHeight
                
                print("moveAmount: \(kbMoveAmount)")
                kbLastHeight = kbHeight
                
                self.animateTextLabel(true)
            }
            
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.animateTextLabel(false)
        print("keyboard hide")
    }

    @IBAction func cancelPost(button:UIBarButtonItem) {
        let rawString: NSString = textView.text
        let whitespace: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let trimmed: NSString = rawString.stringByTrimmingCharactersInSet(whitespace)
        
        if(trimmed.length == 0) {
            // Text was empty or only whitespace.
            self.textView.resignFirstResponder()
            dismissViewControllerAnimated(true, completion: nil)
            
        }
        else {
            displayAlert()

        }
    }
    
    func textViewDidChange(textView: UITextView) {
        self.characterCount = self.maxCharacterCount - textView.text.characters.count
        self.characterCountLabel.text = String(characterCount)
        self.currentCharacterCount = textView.text.characters.count
        print(self.characterCount)
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        findHashtags()
        if textView.text.characters.count - range.length + text.characters.count > self.maxCharacterCount {
            return false
        }
        return true
    }
    
    @IBAction func post(button: UIBarButtonItem) {
        let postJSON = [
            "userId": userId,
            "content": textView.text,
            "hashtags": findHashtags()
        ]
        
        let rawString: NSString = textView.text
        let whitespace: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let trimmed: NSString = rawString.stringByTrimmingCharactersInSet(whitespace)
        
        if(trimmed.length == 0) {
            // Text was empty or only whitespace.
            
        }
        else {
            socket.emit("createPost", postJSON)
            self.textView.resignFirstResponder()
            self.dismissViewControllerAnimated(true, completion: {})
        }
    }
    
    func displayAlert() {
        //NSNotificationCenter.defaultCenter().removeObserver(self)
        //self.toolbar.hidden = true

        let alertView = UIAlertController(title: "Discard?", message: "Your post will not be saved", preferredStyle: .Alert)
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (alertAction) -> Void in
            //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
            //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
            //self.toolbar.hidden = false
        }))
        
        alertView.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (alertAction) -> Void in
            self.textView.resignFirstResponder()
            self.dismissViewControllerAnimated(true, completion: {})
        }))
        
        presentViewController(alertView, animated: true, completion: nil)
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
