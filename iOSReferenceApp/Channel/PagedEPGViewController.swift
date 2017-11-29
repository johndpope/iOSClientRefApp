//
//  PagedEPGViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import Exposure

class PagedEPGViewController: TabmanViewController {

    var viewModel: ChannelListViewModel!
    fileprivate(set) var viewControllers: [EpgViewController] = []
    var brand: Branding.ColorScheme = Branding.ColorScheme.default
    var onPlaybackRequested: (_ program: String?, _ channel: String) -> Void = { _,_ in }
    
    fileprivate var loadStatus: Status = .initial
    enum Status {
        case initial
        case loaded
    }
    
    var activeIndex: Int?
    override func viewDidLoad() {
        super.viewDidLoad()

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
            
            appearance.text.font = UIFont(name: "OpenSans-Light", size: 16)
            
        })
        
        if let conf = dynamicContentCategory {
            prepare(contentFrom: conf)
        }
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
        guard !assets.isEmpty else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewControllers = assets.map{ asset -> EpgViewController in
            let epgViewController = storyboard.instantiateViewController(withIdentifier: "EpgViewController") as! EpgViewController
            epgViewController.authorize(environment: environment,
                                            sessionToken: sessionToken)
            epgViewController.brand = brand
            epgViewController.viewModel.asset = asset
            epgViewController.didSelectEpg = { [weak self] programId, channelId in
                self?.unselectAll(besides: epgViewController)
                self?.onPlaybackRequested(programId, channelId)
            }
            return epgViewController
        }
        
        bar.items = viewControllers.map{ Item(title: $0.viewModel.asset.anyTitle(locale: "en")) }
        reloadPages()
    }
    
    func unselectAll(besides: EpgViewController) {
        viewControllers
            .filter{ $0 != besides }
            .forEach{ $0.mark(index: nil, playing: false) }
    }
}

extension PagedEPGViewController: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        let epgVc = viewControllers[index]
        
        if activeIndex == index {
            epgVc.scrollToLiveOrActive(animated: true)
        }
        activeIndex = index
        
        autoLoadLive(for: epgVc)
        
        return epgVc
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return centerPage
    }
    
    private var centerPage: PageboyViewController.Page {
        return .at(index: viewControllers.count / 2)
    }
    
    func autoLoadLive(for epgVc: EpgViewController) {
        switch loadStatus {
        case .initial:
            let channelId = epgVc.viewModel.channelId
            epgVc.scrollToLiveOrActive(animated: true)
            epgVc.nowPlayingIndex = epgVc.viewModel.currentlyLive()?.row
            onPlaybackRequested(nil,channelId)
            loadStatus = .loaded
        default:
            return
        }
    }
}

extension PagedEPGViewController: AuthorizedEnvironment {
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

extension PagedEPGViewController: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        view.backgroundColor = brand.backdrop.primary
    }
}
