//
//  AppDelegate.swift
//  Peep
//
//  Created by Raymond_Dev on 8/28/15.
//  Copyright (c) 2015 Rayngel. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var socket: SocketIOClient!
    
    var userId: NSString!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        let themeColor: UIColor = UIColor(red: 69/255, green: 173/255, blue: 255/255, alpha: 1)
        let font: UIFont = UIFont(name: "Helvetica-Bold", size: 18)!
        
        //UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().barTintColor = themeColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        //UITabBar.appearance().barTintColor = themeColor
        UITabBar.appearance().tintColor = themeColor
        UITabBar.appearance().translucent = false
        

        
//        UITabBar.appearance().layer.borderWidth = 2;
//        UITabBar.appearance().layer.borderColor = themeColor.CGColor
        
        
//        let tabBarController = self.window?.rootViewController as! UITabBarController
//        let tabBar = tabBarController.tabBar
//        
//        for item in tabBar.items! as [UITabBarItem] {
//            item.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.redColor()], forState: UIControlState.Normal)
//        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        //print("will resign active")
        socket.close(fast: true)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("will enter foreground")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //print("did become active")
        if(socket != nil) {
            socket.open()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

