//
//  AppDelegate.swift
//  MemeMe
//
//  Created by Fred Waltman on 3/11/15.
//  Copyright (c) 2015 Fred Waltman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var memes = [Meme]()

    let startupKey = "MemeStartup-1.0"
    let themeColor = UIColor(red: 0.01, green: 0.22, blue: 0.41, alpha: 1.0)

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
 
        let defaults = NSUserDefaults.standardUserDefaults()


        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
 
        if defaults.boolForKey(startupKey) {
            // already been run, just do segue
            let firstVC = mainStoryboard.instantiateViewControllerWithIdentifier("Main") as UIViewController
            self.window?.rootViewController = firstVC
        } else {
            defaults.setBool(true, forKey: startupKey)
            defaults.synchronize()
            
            let firstVC = mainStoryboard.instantiateViewControllerWithIdentifier("StartupViewController") as UIViewController
            self.window?.rootViewController = firstVC
        }
      
        self.window?.makeKeyAndVisible()


        window?.tintColor = themeColor
        
        let cache = NSURLCache(memoryCapacity: 8 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(cache)
        
        return true
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        NSURLCache.sharedURLCache().removeAllCachedResponses()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

