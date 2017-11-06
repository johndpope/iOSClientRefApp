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
    
    var slidingMenuController: SlidingMenuController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        dataSource = self
        
        bar.style = .scrollingButtonBar
        bar.appearance = TabmanBar.Appearance({ (appearance) in
            appearance.indicator.color = UIColor.ericssonBlue
            appearance.indicator.lineWeight = .thin
            appearance.indicator.compresses = true
            
            appearance.layout.itemDistribution = .centered
            
            appearance.state.selectedColor = UIColor.ericssonBlue
            appearance.state.color = UIColor.white
            
            appearance.style.background = .solid(color: UIColor(red: 0.071, green: 0.075, blue: 0.078, alpha: 1)) //.blur(style: .dark)
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
            
            channelViewController.viewModel.asset = asset
            return channelViewController
        }
        
        bar.items = viewControllers.map{ Item(title: $0.viewModel.asset.anyTitle(locale: "en")) }
        reloadPages()
    }
}

extension PagedChannelViewController: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
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
