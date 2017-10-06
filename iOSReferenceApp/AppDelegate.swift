//
//  AppDelegate.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-03-27.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Utilities
import Download

let TINY_DB = TinyDB.sharedInstance()!

import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        enableAirplayInBackgroundMode()
        
        setupViews()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func setupViews() {
        let uiStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootNavigationController = self.window?.rootViewController as? UINavigationController
        
        let loginViewController = uiStoryboard.instantiateViewController(withIdentifier: Constants.Storyboard.loginId) as UIViewController
        
        // Check user validation
        let stack = UserInfo.isValidSession() ? [loginViewController, uiStoryboard.instantiateViewController(withIdentifier: Constants.Storyboard.homeId) as UIViewController] : [loginViewController]
        
        rootNavigationController?.setViewControllers(stack, animated: false)
    }
}

// MARK: - Enable Airplay in Background Mode
extension AppDelegate {
    fileprivate func enableAirplayInBackgroundMode() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
}

// MARK: - Enable Background Downloads
extension AppDelegate {
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        if identifier == SessionManager.defaultSessionConfigurationIdentifier {
            print("🛏 Rejoining session \(identifier)")
            let sessionManager = SessionManager.default
            sessionManager.backgroundCompletionHandler = completionHandler
            
            sessionManager.restore(assigningRequesterFor: { assetId -> DownloadFairplayRequester? in
                // TODO: Create an asset specific requester (for example from Exposure
                return nil
            }) { downloadTasks in
                downloadTasks.forEach {
                    // Restore state
                    $0.resume()
                }
            }
        }
    }
    
}
