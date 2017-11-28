//
//  TVViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure

class TVViewController: UIViewController {

    var viewModel: ChannelListViewModel!
    var brand: Branding.ColorScheme = Branding.ColorScheme.default
    var slidingMenuController: SlidingMenuController?
    var dynamicContentCategory: DynamicContentCategory?
    
    fileprivate var embeddedPlayerController: PlayerViewController?
    fileprivate weak var playerViewModel: PlayerViewModel?
    
    fileprivate var embeddedEpgController: PagedEPGViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let conf = dynamicContentCategory {
//            embeddedPlayerController.dynamicContentCategory = conf
            embeddedEpgController?.dynamicContentCategory = conf
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleSlidingMenuAction(_ sender: UIBarButtonItem) {
        slidingMenuController?.toggleSlidingMenu()
    }
}
extension TVViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embeddedPlayerView" {
            if let destination = segue.destination as? PlayerViewController {
                embeddedPlayerController = destination
                destination.viewModel = PlayerViewModel(sessionToken: viewModel.sessionToken,
                                                        environment: viewModel.environment)
                destination.brand = brand
                playerViewModel = destination.viewModel
//                destination.dynamicContentCategory = dynamicContentCategory
            }
        }
        else if segue.identifier == "embeddedEpgView" {
            if let destination = segue.destination as? PagedEPGViewController {
                embeddedEpgController = destination
                
                destination.viewModel = ChannelListViewModel(environment: viewModel.environment,
                                                             sessionToken: viewModel.sessionToken)
                destination.brand = brand
                destination.dynamicContentCategory = dynamicContentCategory
                destination.onPlaybackRequested = { [weak self] programId, channelId in
                    self?.playerViewModel?.request(playback: .program(programId: programId, channelId: channelId))
                }
            }
        }
    }
}


extension TVViewController: SlidingMenuDelegate {
    
}

extension TVViewController: AuthorizedEnvironment {
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


extension TVViewController: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        view.backgroundColor = brand.backdrop.primary
    }
}
