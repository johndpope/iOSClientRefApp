//
//  MoreViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-07-12.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure

class MoreViewController: UIViewController {

    @IBOutlet weak var appSloganLabel: UILabel!
    @IBOutlet weak var refAppVersion: UILabel!
    @IBOutlet weak var playerVersion: UILabel!
    @IBOutlet weak var exposureVersion: UILabel!
    @IBOutlet weak var analyticsVersion: UILabel!
    @IBOutlet weak var downloadVersion: UILabel!
    @IBOutlet weak var utilitiesVersion: UILabel!
    
    @IBAction func actionLogout(_ sender: UIButton) {
        defer {
            UserInfo.clear()
            navigationController?.popViewController(animated: true)
        }
        guard let sessionToken = UserInfo.sessionToken, let environment = UserInfo.environment else {
            return
        }
        
        Authenticate(environment: environment)
            .logout(sessionToken: sessionToken)
            .request()
            .validate()
            .response{ (exposureResponse: ExposureResponse<[String:Any]>) in
                if let error = exposureResponse.error {
                    print(error)
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appSloganLabel.text = appSlogan()
        
        refAppVersion.text = framework(identifier: Bundle.main.bundleIdentifier ?? "")
        playerVersion.text = framework(identifier: "com.emp.Player")
        exposureVersion.text = framework(identifier: "com.emp.Exposure")
        analyticsVersion.text = framework(identifier: "com.emp.Analytics")
        downloadVersion.text = framework(identifier: "com.emp.Download")
        utilitiesVersion.text = framework(identifier: "com.emp.Utilities")
    }
    
    func appSlogan() -> String {
        guard let tabVC = self.tabBarController as? HomeTabBarController else {
            return ""
        }
        
        return tabVC.dynamicCustomerConfig?.serviceSlogan ?? ""
    }
    
    func framework(identifier: String) -> String {
        guard let bundleInfo = Bundle(identifier: identifier)?.infoDictionary else { return "?" }
        
        let version = (bundleInfo["CFBundleShortVersionString"] as? String) ?? ""
        guard let build = bundleInfo["CFBundleVersion"] as? String else {
            return version
        }
        return version + " [" + build + "]"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
