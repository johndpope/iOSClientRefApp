//
//  HomeTabBarController.swift
//  iOSReferenceApp
//
//  Created by Hui Wang on 2017-05-19.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure
import Kingfisher

class HomeTabBarController: UITabBarController {

    var config: ApplicationConfig?
    var dynamicCustomerConfig: DynamicCustomerConfig?
    var environment: Environment!
    var sessionToken: SessionToken!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let environment = UserInfo.environment,
            let sessionToken = UserInfo.sessionToken else {
                // TODO: Fail gracefully
                fatalError("Unable to proceed without valid environment")
        }
        self.environment = environment
        self.sessionToken = sessionToken
        
        viewControllers?.forEach {
            if let vc = $0 as? AuthorizedEnvironment {
                    vc.authorize(environment: environment, sessionToken: sessionToken)
            }
        }
        
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -15)
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont(name: "Helvetica", size: 12)!,
             ],
            for: UIControlState.normal)

        applyDynamicConfigUI()
        
        guard let env = UserInfo.environment else { return }
        config = ApplicationConfig(environment: env)
        config?.request { [weak self] in
            self?.loadDynamicConfig()
        }
    }

    func loadDynamicConfig() {
        config?.fetchFile(fileName: "main.json") { [weak self] file in
            if let jsonData = file?.config {
                self?.dynamicCustomerConfig = DynamicCustomerConfig(json: jsonData)
                self?.applyDynamicConfigUI()
            }
        }
    }
    
    func applyDynamicConfigUI() {
        // 1. Tab Bar Title
        if let logoString = dynamicCustomerConfig?.logoUrl, let logoUrl = URL(string: logoString) {
            KingfisherManager.shared.retrieveImage(with: logoUrl, options: logoImageOptions, progressBlock: nil, completionHandler: { [weak self] (image, error, _, _) in
                self?.navigationItem.titleView = UIImageView(image: image)
            })
        }
        else if let preconf = UserInfo.environment?.businessUnit {
            title = preconf
        }
        else {
            title = "My TV"
        }
    }
    
    private var logoImageOptions: KingfisherOptionsInfo {
        let logoSize = CGSize(width: 200, height: 32)
        return [
            .backgroundDecode,
            .cacheMemoryOnly,
            .processor(CrispResizingImageProcessor(referenceSize: logoSize, mode: .aspectFit))
        ]
    }
}
