//
//  PostViewController.swift
//  Peep
//
//  Created by Raymond_Dev on 8/29/15.
//  Copyright (c) 2015 Rayngel. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift

class PostViewController: UIViewController {

    @IBOutlet weak var cancelPostButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    
    var socket: SocketIOClient!
    var toReceive: SocketIOClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.socket = toReceive
        
        cancelPostButton.target = self
        cancelPostButton.action = "cancelPost:"
        
        postButton.target = self
        postButton.action = "post:"
        
        textView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelPost(button:UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func post(button: UIBarButtonItem) {
        //println(textView.text)
        socket.emit("createPost", textView.text)
        socket.emit("reloadPosts")
        self.dismissViewControllerAnimated(true, completion: {})
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
