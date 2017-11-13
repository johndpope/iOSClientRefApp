//
//  ChannelListViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-06.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import Exposure

class PagedChannelViewController: TabmanViewController {
    
    fileprivate(set) var viewControllers: [ChannelViewController] = []
    fileprivate(set) var viewModel: ChannelListViewModel!
    
    var brand: Branding.ColorScheme = Branding.ColorScheme.default
    
    var slidingMenuController: SlidingMenuController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        dataSource = self
        
        bar.style = .scrollingButtonBar
        bar.appearance = TabmanBar.Appearance({ (appearance) in
            appearance.indicator.color = brand.accent
            appearance.indicator.lineWeight = .thin
            appearance.indicator.compresses = true
            
            appearance.layout.itemDistribution = .centered
            
            appearance.state.selectedColor = brand.accent
            appearance.state.color = brand.text.primary
            
            appearance.style.background = .solid(color: brand.backdrop.primary)
            appearance.style.showEdgeFade = true
            
            appearance.text.font = UIFont.systemFont(ofSize: 16)
            
        })
        
        if let conf = dynamicContentCategory {
            prepare(contentFrom: conf)
        }
    }
    
    @IBAction func toggleSlidingMenuAction(_ sender: UIBarButtonItem) {
        slidingMenuController?.toggleSlidingMenu()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var dynamicContentCategory: DynamicContentCategory?
    fileprivate func prepare(contentFrom dynamicContentCategory: DynamicContentCategory) {
        switch dynamicContentCategory.presentation {
        case .tabbedEpg:
            viewModel.loadChannelList{ [weak self] list, error in
                if let list = list {
                    self?.prepareTabs(from: list)
                }
            }
        default:
            print("Please use tabbedEpg when presenting channel lists")
            return
        }
    }
    
    private func prepareTabs(from assets: [Asset]) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewControllers = assets.map{ asset -> ChannelViewController in
            let channelViewController = storyboard.instantiateViewController(withIdentifier: "ChannelViewController") as! ChannelViewController
            channelViewController.authorize(environment: environment,
                                            sessionToken: sessionToken)
            channelViewController.brand = brand
            channelViewController.viewModel.asset = asset
            return channelViewController
        }
        
        bar.items = viewControllers.map{ Item(title: $0.viewModel.asset.anyTitle(locale: "en")) }
        reloadPages()
        
    }
    
//    override func pageboyViewController(_ pageboyViewController: PageboyViewController,
//                                        willScrollToPageAt index: PageboyViewController.PageIndex,
//                                        direction: PageboyViewController.NavigationDirection,
//                                        animated: Bool) {
//        super
//    }
//
//    override func pageboyViewController(_ pageboyViewController: PageboyViewController,
//                                        didScrollTo position: CGPoint,
//                                        direction: PageboyViewController.NavigationDirection,
//                                        animated: Bool) {
//
//    }
//
//    override func pageboyViewController(_ pageboyViewController: PageboyViewController,
//                                        didScrollToPageAt index: PageboyViewController.PageIndex,
//                                        direction: PageboyViewController.NavigationDirection,
//                                        animated: Bool) {
//
//    }
//
//    override func pageboyViewController(_ pageboyViewController: PageboyViewController,
//                                        didReloadWith currentViewController: UIViewController,
//                                        currentPageIndex: PageboyViewController.PageIndex) {
//        super.pageboyViewController(pageboyViewController,
//                                    didReloadWith: currentViewController,
//                                    currentPageIndex: currentPageIndex)
//    }
}

extension PagedChannelViewController: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        let inset = bar.requiredInsets.bar
        print("OFFSET",inset)
        let vc = viewControllers[index]
        if let channelVC = vc as? ChannelViewController {
            channelVC.topContentInsetConstant = inset
        }
        
        return vc
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return centerPage
    }
    
    private var centerPage: PageboyViewController.Page {
        return .at(index: viewControllers.count / 2)
    }
}


extension PagedChannelViewController: SlidingMenuDelegate {

}

extension PagedChannelViewController: AuthorizedEnvironment {
    func authorize(environment: Environment, sessionToken: SessionToken) {
        viewModel = ChannelListViewModel(environment: environment,
                                         sessionToken: sessionToken)
    }
    
    var environment: Environment {
        return viewModel.environment
    }
    
    var sessionToken: SessionToken {
        return viewModel.sessionToken
    }
}

extension PagedChannelViewController: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        view.backgroundColor = brand.backdrop.primary
    }
}
