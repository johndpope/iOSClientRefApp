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

    override func viewDidLoad() {
        super.viewDidLoad()

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
        config?.setup { [weak self] in
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
            let logoSize = CGSize(width: 200, height: 32)
            let logoView = UIView(frame: CGRect(x: 0, y: 0, width: logoSize.width, height: logoSize.height))
            let resizeProcessor = ResizingImageProcessor(referenceSize: logoSize, mode: .aspectFit)
            KingfisherManager.shared.retrieveImage(with: logoUrl, options: [.processor(resizeProcessor)], progressBlock: nil, completionHandler: { [weak self] (image, error, _, _) in
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
//    func fetchFile(name: String? = nil) {
//        var name = name
//        if name == nil {
//            name = config?.customerConfig?.fileNames.first
//        }
//        guard let fileName = name else { return }
//        config?.fetchFile(fileName: fileName,
//                          completion: { [weak self] file in
//                            self?.appConfigFile = file
//        })
//    }

}
