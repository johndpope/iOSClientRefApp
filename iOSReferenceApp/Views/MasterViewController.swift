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
//

    fileprivate let menuConstants = MenuConstants()
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var contentContainer: UIView!
    
    fileprivate var menuController: MainMenuViewController!
    var animator: UIDynamicAnimator!
    var itemBehavior: UIDynamicItemBehavior!
    var snapBehavior: UISnapBehavior!
    var  attachmentBehavior: UIAttachmentBehavior!
    
    var config: ApplicationConfig?
    var dynamicCustomerConfig: DynamicCustomerConfig?
    var environment: Environment!
    var sessionToken: SessionToken!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = UIDynamicAnimator(referenceView: view)
        itemBehavior = UIDynamicItemBehavior(items: [contentContainer])
        itemBehavior.allowsRotation = false
        blurView.effect = nil
        
        
        
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
    @IBAction func blurViewTapAction(_ sender: UITapGestureRecognizer) {
        toggleSlidingMenu()
    }
    
    @IBAction func blurViewSwipeAction(_ sender: UIPanGestureRecognizer) {
        let location = sender.translation(in: view)
        switch sender.state {
        case .began:
            let anchor = CGPoint(x: snapBehavior.snapPoint.x, y: view.bounds.midY)
            let vector = CGVector(dx: 1, dy: 0)
            attachmentBehavior = UIAttachmentBehavior.slidingAttachment(with: contentContainer, attachmentAnchor: anchor, axisOfTranslation: vector)
            attachmentBehavior.attachmentRange = UIFloatRange(minimum: 0, maximum: 100)
            
            animator.addBehavior(attachmentBehavior)
            
        case .ended:
            let maxOffset = menuConstants.inset(for: view.bounds.size.width)
            print(maxOffset+location.x,maxOffset, 0.5*maxOffset)
            if maxOffset+location.x < 0.75*maxOffset {
                // Hide menu
                animator.removeBehavior(attachmentBehavior)
                menuOpen = false
                blurView.isUserInteractionEnabled = false
                
                
                let x = contentContainer.bounds.midX
                let y = contentContainer.frame.midY
                
                animator.addBehavior(snapBehavior)
                snapBehavior.snapPoint = CGPoint(x: x, y: y)
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                    self?.blurView.effect = nil
                })
            }
            else {
                // Keep menu
                let x = contentContainer.bounds.midX + menuConstants.inset(for: view.bounds.size.width)
                let y = contentContainer.frame.midY
                
                animator.removeBehavior(attachmentBehavior)
                
                animator.addBehavior(snapBehavior)
                snapBehavior.snapPoint = CGPoint(x: x, y: y)
            }
        default:
            attachmentBehavior.anchorPoint = CGPoint(x: snapBehavior.snapPoint.x+location.x, y: view.bounds.midY)
        }
    }
    
    enum Segue: String {
        case masterToMainMenu = "masterToMainMenu"
        case masterToContent = "masterToContent"
    }
    
    var menuOpen: Bool = false
}

extension MasterViewController: SlidingMenuController {
    func moveSlidingMenu(offset: CGFloat) {
        print(offset)
    }
    
    func toggleSlidingMenu() {
        if menuOpen {
            menuOpen = false
            blurView.isUserInteractionEnabled = false

            print("toggle back")
            let x = contentContainer.frame.midX - menuConstants.inset(for: view.bounds.size.width)
            let y = contentContainer.frame.midY
            
            print("SnapToEND",CGPoint(x: x, y: y))
            snapBehavior.snapPoint = CGPoint(x: x, y: y)
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                self?.blurView.effect = nil
            })
        }
        else {
            menuOpen = true
            blurView.isUserInteractionEnabled = true
            animator.removeAllBehaviors()

            let x = contentContainer.frame.midX + menuConstants.inset(for: view.bounds.size.width)
            let y = contentContainer.frame.midY

            print("SnapTo",CGPoint(x: x, y: y))
            snapBehavior = UISnapBehavior(item: contentContainer, snapTo: CGPoint(x: x, y: y))
            snapBehavior.damping = 0.75
            animator.addBehavior(snapBehavior)

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                self?.blurView.effect = UIBlurEffect(style: .dark)
            })

        }
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
