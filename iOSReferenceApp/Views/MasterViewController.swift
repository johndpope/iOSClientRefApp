//
//  MasterViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-27.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure
import Kingfisher

protocol SlidingMenuController {
    func toggleSlidingMenu()
}

protocol SlidingMenuDelegate: class {
    var slidingMenuController: SlidingMenuController? { get set }
}

class MasterViewController: UIViewController {

    struct MenuConstants {
        let defaultInset: CGFloat = 0
        let maxInset: CGFloat = 320
        let maxPercentInset: CGFloat = 0.70
        
        func inset(for width: CGFloat) -> CGFloat {
            let percent = width*maxPercentInset
            return percent > maxInset ? maxInset : percent
        }
    }
    
    fileprivate let menuConstants = MenuConstants()
    @IBOutlet weak var leadingContentConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingContentConstraint: NSLayoutConstraint!
    
    fileprivate var menuController: MainMenuViewController!
    
    var config: ApplicationConfig?
    var dynamicCustomerConfig: DynamicCustomerConfig?
    var environment: Environment!
    var sessionToken: SessionToken!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        applyDynamicConfigUI()
        
        
        guard let env = UserInfo.environment else { return }
        config = ApplicationConfig(environment: env)
        config?.setup { [weak self] in
//            self?.loadDynamicConfig()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationItem.hidesBackButton = true
        
        menuController.constrain(width: menuConstants.inset(for: view.bounds.size.width))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func loadDynamicConfig() {
//        config?.fetchFile(fileName: "main.json") { [weak self] file in
//            if let jsonData = file?.config {
//                self?.dynamicCustomerConfig = DynamicCustomerConfig(json: jsonData)
//                self?.applyDynamicConfigUI()
//            }
//        }
//    }
//
//    func applyDynamicConfigUI() {
//        // 1. Tab Bar Title
//        if let logoString = dynamicCustomerConfig?.logoUrl, let logoUrl = URL(string: logoString) {
//            KingfisherManager.shared.retrieveImage(with: logoUrl, options: logoImageOptions, progressBlock: nil, completionHandler: { [weak self] (image, error, _, _) in
//                self?.navigationItem.titleView = UIImageView(image: image)
//            })
//        }
//        else if let preconf = UserInfo.environment?.businessUnit {
//            title = preconf
//        }
//        else {
//            title = "My TV"
//        }
//    }
//
//    private var logoImageOptions: KingfisherOptionsInfo {
//        let logoSize = CGSize(width: 200, height: 32)
//        return [
//            .backgroundDecode,
//            .cacheMemoryOnly,
//            .processor(CrispResizingImageProcessor(referenceSize: logoSize, mode: .aspectFit))
//        ]
//    }
    
    enum Segue: String {
        case masterToMainMenu = "masterToMainMenu"
        case masterToContent = "masterToContent"
    }
}

extension MasterViewController: SlidingMenuController {
    private var menuIsOpen: Bool {
        return leadingContentConstraint.constant != menuConstants.defaultInset
    }
    func toggleSlidingMenu() {
        leadingContentConstraint.constant = menuIsOpen ? menuConstants.defaultInset : menuConstants.inset(for: view.bounds.size.width)
        trailingContentConstraint.constant = menuIsOpen ? menuConstants.defaultInset : -menuConstants.inset(for: view.bounds.size.width)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

extension MasterViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let environment = UserInfo.environment,
            let sessionToken = UserInfo.sessionToken else {
                // TODO: Fail gracefully
                fatalError("Unable to proceed without valid environment")
        }
        self.environment = environment
        self.sessionToken = sessionToken
        
        if segue.identifier == Segue.masterToContent.rawValue, let navController = segue.destination as? UINavigationController {
            if let destination = navController.viewControllers.first as? AuthorizedEnvironment {
                destination.authorize(environment: environment,
                                      sessionToken: sessionToken)
            }
            
            if let destination = navController.viewControllers.first as? SlidingMenuDelegate {
                destination.slidingMenuController = self
            }
        }
        else if segue.identifier == Segue.masterToMainMenu.rawValue, let destination = segue.destination as? MainMenuViewController {
            menuController = destination
        }
    }
}
