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
import GoogleCast
import Cast

class MasterViewController: UIViewController {
    let interactor = Interactor()
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var contentContainer: UIView!
    
    fileprivate var contentNavContainer: UINavigationController!
    
    var castChannel: Channel = Channel()
    var castSession: GCKCastSession?
    
    var environment: Exposure.Environment!
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
        case .simpleCarousel:
            prepareChannelView()
        }
        
    }
    
    func configure(carouselController: SingleCarouselViewController, dynamicContent: DynamicContentCategory? = nil) {
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
    func actionLogout() {
        defer {
            UserInfo.clearSession()
            navigationController?.popViewController(animated: true)
        }
        Authenticate(environment: environment)
            .logout(sessionToken: sessionToken)
            .request()
            .validate()
            .rawResponse { _,_,_, error in
                if let error = error {
                    print(error)
                }
        }
    }
}

extension MasterViewController {
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

extension MasterViewController: ChromeCaster {
    
    var castEnvironment: Cast.Environment {
        return Cast.Environment(baseUrl: environment.baseUrl,
                                customer: environment.customer,
                                businessUnit: environment.businessUnit,
                                sessionToken: sessionToken.value)
    }
}

extension MasterViewController {
    var hasActiveChromecastSession: Bool {
        return GCKCastContext.sharedInstance().sessionManager.hasConnectedCastSession()
    }
    
    func prepareChannelView() {
        epgSelectionView{  [weak self] channel, program in
            guard let `self` = self else { return }
            if self.hasActiveChromecastSession {
                // Load ChromeCasting
                if let program = program {
                    self.loadChromeCast(for: PlayerViewModel.PlayRequest.program(playable: program.programPlayable, metaData: program.asset), localOffset: nil)
                }
                else {
                    self.loadChromeCast(for: PlayerViewModel.PlayRequest.live(playable: channel.channelPlayable, metaData: channel), localOffset: nil)
                }
                
            }
            else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
                
                let playRequest = program != nil ? PlayerViewModel.PlayRequest.program(playable: program!.programPlayable, metaData: program?.asset) : PlayerViewModel.PlayRequest.live(playable: channel.channelPlayable, metaData: channel)
                viewController.viewModel = PlayerViewModel(sessionToken: self.sessionToken, environment: self.environment, playRequest: playRequest)
                viewController.brand = self.brand
                viewController.onChromeCastRequested = { [weak self] request, currentTime in
                    self?.dismiss(animated: true)
                    self?.loadChromeCast(for: request, localOffset: currentTime)
                }
                viewController.onDismissed = { [weak self] in
                    self?.dismiss(animated: true)
                }
                
                self.present(viewController, animated: true)
            }
        }
    }
    func accessTestEnv() {
        epgSelectionView{ [weak self] channel, program in
            guard let `self` = self else { return }
            let storyboard = UIStoryboard(name: "TestEnv", bundle: nil)
            let timeshiftViewController = storyboard.instantiateViewController(withIdentifier: "TestEnvTimeshiftDelay") as! TestEnvTimeshiftDelay
            
            timeshiftViewController.program = program
            timeshiftViewController.channel = channel
            timeshiftViewController.environment = self.environment
            timeshiftViewController.sessionToken = self.sessionToken
            
            self.contentNavContainer.pushViewController(timeshiftViewController, animated: true)
        }
    }
    
    func epgSelectionView(callback: @escaping (Asset, Program?) -> Void) {
        let viewController = SimpleCarouselViewController<Asset>(nibName: "SimpleCarouselViewController", bundle: nil)
        viewController.navigationItem.title = "Channels"
        viewController.viewModel.executeResuest = { [weak self, weak viewController] in
            guard let `self` = self else { return }
            FetchAsset(environment: self.environment)
                .list()
                .includeUserData(for: self.sessionToken)
                .elasticSearch(query: "(medias.drm:FAIRPLAY OR medias.drm:UNENCRYPTED) AND medias.format:HLS")
                .filter(on: "TV_CHANNEL")
                .filter(onlyPublished: true)
                .sort(on: ["assetId","originalTitle"])
                .request()
                .validate()
                .response{ [weak self] in
                    if let error = $0.error {
                        self?.showMessage(title: "epgSelectionView: \(error.code)", message: error.message)
                    }
                    if let value = $0.value {
                        viewController?.viewModel.prepare(content: value.items, error: nil)
                    }
            }
        }
        
        viewController.viewModel.onPrepared = { [unowned viewController] _,_ in
            viewController.collectionView.reloadSections([0])
        }
        
        viewController.onSelected = { [weak self] channelAsset in
            guard let `self` = self, let channelAsset = channelAsset else { return }
            
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) { [weak self] action in
                
            }
            
            let alert = UIAlertController(title: "PlaybackMode", message: "Please select the desired playback mode", preferredStyle: UIAlertControllerStyle.alert)
            let channelPlay = UIAlertAction(title: "Channel Play", style: UIAlertActionStyle.default) { [weak self] action in
                callback(channelAsset,nil)
            }
            
            let programPlay = UIAlertAction(title: "Program Play", style: UIAlertActionStyle.default) { [weak self] action in
                guard let `self` = self else { return }
                
                let epgViewController = SimpleEpgViewController(nibName: "SimpleEpgViewController", bundle: nil)
                epgViewController.navigationItem.title = channelAsset.anyTitle(locale: "en")
                epgViewController.onSelected = { [weak self] model in
                    callback(channelAsset,model)
                }
                
                epgViewController.viewModel.executeResuest = { [weak self, unowned epgViewController] in
                    guard let `self` = self else { return }
                    let current = Date()
                    FetchEpg(environment: self.environment)
                        .channel(id: channelAsset.assetId)
                        .show(page: 1, spanning: 500)
                        .filter(starting: current.subtract(days: 1), ending: current.add(days: 1) ?? current)
                        .request()
                        .validate()
                        .response{
                            epgViewController.viewModel.prepare(content: $0.value?.programs, error: $0.error)
                    }
                }
                
                epgViewController.viewModel.onPrepared = { [weak self, unowned epgViewController] _,error in
                    if let error = error {
                        self?.showMessage(title: "EPG Error \(error.code)", message: error.message)
                    }
                    epgViewController.tableView.reloadSections([0], with: .automatic)
                    if let liveIndex = epgViewController.viewModel.currentlyLiveIndex {
                        epgViewController.tableView.scrollToRow(at: liveIndex, at: .middle, animated: true)
                    }
                }
                
                self.contentNavContainer.pushViewController(epgViewController, animated: true)
            }
            alert.addAction(channelPlay)
            alert.addAction(programPlay)
            alert.addAction(cancel)
            self.present(alert, animated: true)
            
        }
        
        viewController.slidingMenuController = self
//        viewController.brand = brand
        
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "download-list"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MasterViewController.toggleSlidingMenu))
        contentNavContainer.setViewControllers([viewController], animated: true)
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
//            contentNavContainer.delegate = self
            
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
                self?.closeMenu()
                switch segue {
                case .myDownloads:
                    self?.configureMyDownloads()
                case .logout:
                    self?.actionLogout()
                case .testEnv:
                    self?.accessTestEnv()
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
