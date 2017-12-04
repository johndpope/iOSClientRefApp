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
    let interactor = Interactor()
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var contentContainer: UIView!
    
    fileprivate var contentNavContainer: UINavigationController!
    
    
    var environment: Environment!
    var sessionToken: SessionToken!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurView.effect = nil
    }
    
    var activeContentIndex: Int? = 0
    var dynamicCustomerConfig: DynamicCustomerConfig? {
        didSet {
            if let dynamicConfig = dynamicCustomerConfig {
                apply(brand: dynamicConfig.colorScheme)
                
                let contentCategory = MainMenuViewModel
                    .resolveHomeViewModel(for: dynamicConfig.carouselGroupId)
                    .dynamicContent
                createNewCarousel(from: contentCategory)
            }
        }
    }
    
    var brand: Branding.ColorScheme {
        return dynamicCustomerConfig?.colorScheme ?? Branding.ColorScheme.default
    }
    
    func createNewCarousel(from dynamicContent: DynamicContentCategory) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch dynamicContent.presentation {
        case .singleCarousel:
            let viewController = storyboard.instantiateViewController(withIdentifier: "SingleCarouselViewController") as! SingleCarouselViewController
            configure(carouselController: viewController, dynamicContent: dynamicContent)
            contentNavContainer.setViewControllers([viewController], animated: true)
        case .multiCarousel:
            let viewController = storyboard.instantiateViewController(withIdentifier: "CarouselListViewController") as! CarouselListViewController
            configure(carouselController: viewController, dynamicContent: dynamicContent)
            contentNavContainer.setViewControllers([viewController], animated: true)
        case .tabbedEpg:
            let viewController = storyboard.instantiateViewController(withIdentifier: "TVViewController") as! TVViewController
            configure(carouselController: viewController, dynamicContent: dynamicContent)
            contentNavContainer.setViewControllers([viewController], animated: true)
        }
        
    }
    
    func configure(carouselController: SingleCarouselViewController, dynamicContent: DynamicContentCategory? = nil) {
        carouselController.authorize(environment: environment,
                                     sessionToken: sessionToken)
        carouselController.slidingMenuController = self
        carouselController.brand = brand
        carouselController.dynamicContentCategory = dynamicContent
    }
    
    func configure(carouselController: TVViewController, dynamicContent: DynamicContentCategory? = nil) {
        carouselController.authorize(environment: environment,
                                     sessionToken: sessionToken)
        carouselController.slidingMenuController = self
        carouselController.brand = brand
        carouselController.dynamicContentCategory = dynamicContent
    }
    
    func configure(carouselController: CarouselListViewController, dynamicContent: DynamicContentCategory? = nil) {
        carouselController.authorize(environment: environment,
                                     sessionToken: sessionToken)
        carouselController.slidingMenuController = self
        carouselController.brand = brand
        carouselController.dynamicContentCategory = dynamicContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationItem.hidesBackButton = true
        
        apply(brand: brand)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    enum Segue: String {
        case masterToMainMenu = "masterToMainMenu"
        case masterToContent = "masterToContent"
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
//        blurView.isUserInteractionEnabled = true
//        blurView.effect = UIBlurEffect(style: .dark)
        
        performSegue(withIdentifier: "masterToMainMenu", sender: nil)
    }
    func closeMenu() {
        guard menuOpen else { return }
        menuOpen = false
//        blurView.isUserInteractionEnabled = false
//        blurView.effect = nil
        
        dismiss(animated: true)
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
            
            contentNavContainer.apply(brand: brand)
            
            configure(carouselController: destination)
        }
        else if segue.identifier == Segue.masterToMainMenu.rawValue, let destination = segue.destination as? MainMenuViewController {
            destination.dynamicCustomerConfig = dynamicCustomerConfig
            destination.transitioningDelegate = self
            destination.authorize(environment: environment,
                                  sessionToken: sessionToken)
            destination.initailyActiveContentIndex = activeContentIndex
            
            destination.interactor = interactor
            destination.closeMenu = { [weak self] in
                self?.closeMenu()
            }
            destination.selectedOtherSegue = { [weak self] segue in
                self?.activeContentIndex = nil
                switch segue {
                case .myDownloads:
                    self?.closeMenu()
                    self?.configureMyDownloads()
                }
            }
            destination.selectedContentSegue = { [weak self] dynamicContentCategory, index in
                self?.closeMenu()
                if self?.activeContentIndex != index {
                    self?.activeContentIndex = index
                    self?.createNewCarousel(from: dynamicContentCategory)
                }
            }
        }
    }
    
    func configureMyDownloads() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "OfflineListViewController") as! OfflineListViewController
        
        viewController.slidingMenuController = self
        viewController.authorize(environment: environment,
                                 sessionToken: sessionToken)
        viewController.brand = brand
        contentNavContainer.setViewControllers([viewController], animated: true)
    }
}

extension MasterViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
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

extension MasterViewController: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.backgroundColor = brand.backdrop.primary
            self?.contentNavContainer.apply(brand: brand)
        }
    }
}
