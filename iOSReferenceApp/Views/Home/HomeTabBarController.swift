//
//  HomeTabBarController.swift
//  iOSReferenceApp
//
//  Created by Hui Wang on 2017-05-19.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure

class HomeTabBarController: UITabBarController {

    var config: ApplicationConfig?
    var appConfigFile: Exposure.CustomerConfig.File?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        self.title = UserInfo.environment?.customer
        
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -15)
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont(name: "Helvetica", size: 12)!,
             ],
            for: UIControlState.normal)

        guard let env = UserInfo.environment else { return }
        config = ApplicationConfig(environment: env)
        config?.setup {
            self.fetchFile(name: "main.json")
        }
    }

    func fetchFile(name: String? = nil) {
        var name = name
        if name == nil {
            name = config?.customerConfig?.fileNames.first
        }
        guard let fileName = name else { return }
        config?.fetchFile(fileName: fileName,
                          completion: { [weak self] file in
                            self?.appConfigFile = file
        })
    }

}
