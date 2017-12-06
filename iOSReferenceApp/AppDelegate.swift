
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
import Cast
import GoogleCast

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        enableAirplayInBackgroundMode()
        
        let options = GCKCastOptions(discoveryCriteria: GCKDiscoveryCriteria(applicationID: "6AB327C1"))
        GCKCastContext.setSharedInstanceWith(options)
        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
//        setupCastLogging()
        
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
        if let rootNavigationController = self.window?.rootViewController as? UINavigationController {
            
            rootNavigationController.setNavigationBarHidden(true, animated: false)
            rootNavigationController.navigationBar.barStyle = .black
            
            let stack = initialStack()
            rootNavigationController.setViewControllers(stack, animated: false)
            
            // Activate the ChromeCast root container.
            let castContainer = GCKCastContext.sharedInstance().createCastContainerController(for: rootNavigationController)
            window?.rootViewController = castContainer
        }
    }
        
    func initialStack() -> [UIViewController] {
        let uiStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let environmentViewController = uiStoryboard.instantiateViewController(withIdentifier: "EnvironmentSelection") as! EnvironmentSelectionViewController
        guard let environment = UserInfo.environment else {
            return [environmentViewController]
        }
        
        let loginViewController = uiStoryboard.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
        loginViewController.viewModel = LoginViewModel(environment: environment,
                                                       useMfa: UserInfo.environmentUsesMfa)
        
        guard UserInfo.sessionToken != nil else {
            retrieveDynamicCustomerConfig(for: environment) { conf in
                if let conf = conf {
                    loginViewController.dynamicCustomerConfig = conf
                }
            }
            return [environmentViewController, loginViewController]
        }
        
        let masterViewController = uiStoryboard.instantiateViewController(withIdentifier: Constants.Storyboard.masterView) as! MasterViewController
        retrieveDynamicCustomerConfig(for: environment) { conf in
            if let conf = conf {
                loginViewController.dynamicCustomerConfig = conf
                masterViewController.dynamicCustomerConfig = conf
            }
        }
        return [environmentViewController, loginViewController, masterViewController]
    }
    
    func retrieveDynamicCustomerConfig(for environment: Exposure.Environment, callback: @escaping (DynamicCustomerConfig?) -> Void) {
        
        ApplicationConfig(environment: environment)
            .fetchFile(fileName: "main.json") {
                if let jsonData = $0?.config, let dynamicConfig = DynamicCustomerConfig(json: jsonData) {
                    callback(dynamicConfig)
                }
        }
    }
    
    func setupCastLogging() {
        let logFilter = GCKLoggerFilter()
        let classesToLog = ["GCKDeviceScanner", "GCKDeviceProvider", "GCKDiscoveryManager", "GCKCastChannel",
                            "GCKMediaControlChannel", "GCKUICastButton", "GCKUIMediaController", "NSMutableDictionary"]
        logFilter.setLoggingLevel(.verbose, forClasses: classesToLog)
        GCKLogger.sharedInstance().filter = logFilter
        GCKLogger.sharedInstance().delegate = self
    }
}

// MARK: - GCKLoggerDelegate
extension AppDelegate: GCKLoggerDelegate {
    func logMessage(_ message: String, fromFunction function: String) {
        print("\(function)  \(message)")
    }
}

// MARK: - GCKSessionManagerListener
extension AppDelegate: GCKSessionManagerListener {
    
    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKSession, withError error: Error?) {
        if error == nil {
            print("GCKSessionManagerListener Session ended")
        } else {
            print("GCKSessionManagerListener Session ended unexpectedly:\n \(error?.localizedDescription ?? "")")
        }
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKSession, withError error: Error) {
        print("GCKSessionManagerListener Failed to start session:\n\(error.localizedDescription)")
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
            .onPrepared { _ in
                print("📱 Media Download prepared")
            }
            .onSuspended { _ in
                print("📱 Media Download Suspended")
            }
            .onResumed { _ in
                print("📱 Media Download Resumed")
            }
            .onProgress { _, progress in
                print("📱 Percent",progress.current*100,"%")
            }
            .onShouldDownloadMediaOption{ _ in
                print("📱 Select media option")
                return nil
            }
            .onDownloadingMediaOption{ _ in
                print("📱 Downloading media option")
            }
            .onError {_, url, error in
                print("📱 Download error: \(error)",url)
            }
            .onCompleted { _, url in
                print("📱 Download completed: \(url)")
            }
            .resume()
    }
}
