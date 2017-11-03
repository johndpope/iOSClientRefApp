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
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var contentContainer: UIView!
    
    fileprivate var menuController: MainMenuViewController!
    
    fileprivate var contentNavContainer: UINavigationController!
    fileprivate var contentController: CarouselListViewController!
    
    var animator: UIDynamicAnimator!
    var itemBehavior: UIDynamicItemBehavior!
    var snapBehavior: UISnapBehavior!
    var attachmentBehavior: UIAttachmentBehavior!
    
    var environment: Environment!
    var sessionToken: SessionToken!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = UIDynamicAnimator(referenceView: view)
        itemBehavior = UIDynamicItemBehavior(items: [contentContainer])
        itemBehavior.allowsRotation = false
        blurView.effect = nil
    }
    
    var dynamicCustomerConfig: DynamicCustomerConfig? {
        didSet {
            menuController.dynamicCustomerConfig = dynamicCustomerConfig
        }
    }
    
    func createNewCarousel(from dynamicContent: DynamicContentCategory) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let CarouselListViewController = storyboard.instantiateViewController(withIdentifier: "CarouselListViewController") as! CarouselListViewController
        
        configure(carouselController: CarouselListViewController, dynamicContent: dynamicContent)
        
        contentNavContainer.setViewControllers([CarouselListViewController], animated: true)
    }
    
    func configure(carouselController: CarouselListViewController, dynamicContent: DynamicContentCategory? = nil) {
        contentController = carouselController
        
        carouselController.authorize(environment: environment,
                                  sessionToken: sessionToken)
        carouselController.slidingMenuController = self
        carouselController.dynamicContentCategory = dynamicContent
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
        case masterToMyDownloads = "masterToMyDownloads"
    }
    
    var menuOpen: Bool = false
}

extension MasterViewController: SlidingMenuController {
    func toggleSlidingMenu() {
        if menuOpen {
            closeMenu()
        }
        else {
            openMenu()
        }
    }
    func openMenu() {
        guard !menuOpen else { return }
        menuOpen = true
        blurView.isUserInteractionEnabled = true
        animator.removeAllBehaviors()
        
        let x = contentContainer.frame.midX + menuConstants.inset(for: view.bounds.size.width)
        let y = contentContainer.frame.midY
        
        snapBehavior = UISnapBehavior(item: contentContainer, snapTo: CGPoint(x: x, y: y))
        snapBehavior.damping = 0.75
        animator.addBehavior(snapBehavior)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            self?.blurView.effect = UIBlurEffect(style: .dark)
        })

    }
    func closeMenu() {
        guard menuOpen else { return }
        menuOpen = false
        blurView.isUserInteractionEnabled = false
        
        let x = contentContainer.frame.midX - menuConstants.inset(for: view.bounds.size.width)
        let y = contentContainer.frame.midY
        
        snapBehavior.snapPoint = CGPoint(x: x, y: y)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            self?.blurView.effect = nil
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
        
        if segue.identifier == Segue.masterToContent.rawValue, let navController = segue.destination as? UINavigationController, let destination = navController.viewControllers.first as? CarouselListViewController {
            contentNavContainer = navController
            contentNavContainer.delegate = self
            configure(carouselController: destination)
        }
        else if segue.identifier == Segue.masterToMainMenu.rawValue, let destination = segue.destination as? MainMenuViewController {
            menuController = destination
            destination.authorize(environment: environment,
                                  sessionToken: sessionToken)
            destination.selectedOtherSegue = { [weak self] segue in
                switch segue {
                case .myDownloads: self?.performSegue(withIdentifier: Segue.masterToMyDownloads.rawValue, sender: nil)
                }
            }
            destination.selectedContentSegue = { [weak self] dynamicContentCategory in
                self?.closeMenu()
                self?.createNewCarousel(from: dynamicContentCategory)
            }
        }
        else if segue.identifier == Segue.masterToMyDownloads.rawValue {
            if let destination = segue.destination as? OfflineListViewController {
                destination.authorize(environment: environment,
                                      sessionToken: sessionToken)
            }
        }
    }
}

extension MasterViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let frame = fromVC.view.frame
        
        switch operation {
        case .push:
            return ContentCarouselTransition(duration: TimeInterval(UINavigationControllerHideShowBarDuration), isPresenting: true, originFrame: frame)
        case .pop:
            return ContentCarouselTransition(duration: TimeInterval(UINavigationControllerHideShowBarDuration), isPresenting: false, originFrame: frame)
        case .none:
            return ContentCarouselTransition(duration: TimeInterval(UINavigationControllerHideShowBarDuration), isPresenting: false, originFrame: frame)
        }
    }
}
