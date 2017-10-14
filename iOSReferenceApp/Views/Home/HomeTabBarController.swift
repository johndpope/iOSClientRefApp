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

        //ImageCache.default.clearDiskCache()
        
        
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
    
    func resize(image: UIImage?, newSize: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        guard let imageRef = image.cgImage else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        defer { UIGraphicsEndImageContext() }
        
        // Set the quality level to use when rescaling
        context.interpolationQuality = .high
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
        
        context.concatenate(flipVertical)
        // Draw into the context; this scales the image
        context.draw(imageRef, in: newRect)
        
        guard let newImageRef = context.makeImage() else { return nil }
        
        // Get the resized image from the context and a UIImage
        return UIImage(cgImage: newImageRef)
    }
    
    func aspectFit(base: CGSize, size: CGSize) -> CGSize {
        let aspectRatio = base.height == 0.0 ? 1.0 : base.width / base.height
        let aspectWidth = round(aspectRatio * size.height)
        let aspectHeight = round(size.width / aspectRatio)
        
        return aspectWidth > size.width ? CGSize(width: size.width, height: aspectHeight) : CGSize(width: aspectWidth, height: size.height)
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
