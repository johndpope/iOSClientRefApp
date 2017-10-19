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
import Exposure

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
        print(#function)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print(#function)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print(#function)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print(#function)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print(#function)
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
        if identifier == SessionConfigurationIdentifier.default.rawValue {
            print("🛏 Rejoining session \(identifier)")
            let sessionManager = ExposureSessionManager.shared.manager
            sessionManager.backgroundCompletionHandler = completionHandler
            
            sessionManager.restoreTasks { downloadTasks in
                downloadTasks.forEach {
                    print("🛏 found",$0.taskDescription)
                    // Restore state
//                    log(downloadTask: $0)
                }
            }
        }
    }
    
    private func log(downloadTask: ExposureDownloadTask) {
        downloadTask.onCanceled{ task, url in
                print("📱 Media Download canceled",task.configuration.identifier,url)
            }
            .onPrepared { [weak self] task in
                print("📱 Media Download prepared")
            }
            .onSuspended { [weak self] task in
                print("📱 Media Download Suspended")
            }
            .onResumed { [weak self] task in
                print("📱 Media Download Resumed")
            }
            .onProgress { [weak self] task, progress in
                print("📱 Percent",progress.current*100,"%")
            }
            .onShouldDownloadMediaOption{ task, options in
                print("📱 Select media option")
                return nil
            }
            .onDownloadingMediaOption{ task, option in
                print("📱 Downloading media option")
            }
            .onError { [weak self] task, url, error in
                print("📱 Download error: \(error)",url)
            }
            .onCompleted { [weak self] task, url in
                print("📱 Download completed: \(url)")
            }
            .resume()
    }
}
