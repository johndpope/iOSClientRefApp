//
//  ChannelViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-06.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure

class ChannelViewController: UIViewController {

    var topContentInsetConstant: CGFloat = 0
    @IBOutlet weak var topContentInset: NSLayoutConstraint!
    @IBOutlet weak var epgTableView: UITableView!
    
    var brand: Branding.ColorScheme = Branding.ColorScheme.default
    
    fileprivate(set) var viewModel: ChannelViewModel!
    
    fileprivate var embeddedPlayerController: PlayerViewController?
    fileprivate weak var playerViewModel: PlayerViewModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        epgTableView.delegate = self
        epgTableView.dataSource = self
        
        epgTableView.register(UINib(nibName: "EPGPreviewCell", bundle: nil),
                              forCellReuseIdentifier: "EPGPreviewCell")
        
        prepareEpg()
        apply(brand: brand)
        topContentInset.constant = topContentInsetConstant
        view.layoutIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollToLive(animated: animated)
        // TODO:
        playerViewModel?.request(playback: .live(channelId: viewModel.channelId))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        embeddedPlayerController?.player.stop() // TODO: Move to onMovedToTab
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func prepareEpg() {
//        channelTitleLabel.setTitle(viewModel.anyTitle(locale: "en"), for: [])
        
        let current = Date()
        viewModel.fetchEPG(starting: current.subtract(days: 1), ending: current.add(days: 1) ?? current) { [weak self] error in
            if let error = error {
                self?.showMessage(title: "EPG Error", message: error.localizedDescription)
            }
            else {
                self?.epgTableView.reloadData()
                self?.scrollToLive(animated: true)
            }
        }
    }
}

extension ChannelViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embeddedPlayerView" {
            if let destination = segue.destination as? PlayerViewController {
                embeddedPlayerController = destination
                destination.viewModel = PlayerViewModel(sessionToken: viewModel.sessionToken,
                                                        environment: viewModel.environment)
                playerViewModel = destination.viewModel
            }
        }
    }
}

extension ChannelViewController {
    func scrollToLive(animated: Bool) {
        guard let liveRow = viewModel.currentlyLive() else { return }
        epgTableView.scrollToRow(at: liveRow, at: .middle, animated: animated)
    }
}

extension ChannelViewController:  UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.rowHeight(index: indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return !viewModel.content[indexPath.row].isUpcoming
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let programId = viewModel.content[indexPath.row].program.assetId else { return }
        playerViewModel?.request(playback: .catchup(channelId: viewModel.channelId, programId: programId))
    }
}

extension ChannelViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EPGPreviewCell") as! EPGPreviewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let preview = cell as? EPGPreviewCell {
            let vm = viewModel.content[indexPath.row]
            
            preview.reset()
            preview.bind(viewModel: vm)
            preview.apply(brand: brand)
        }
    }
}

extension ChannelViewController: AuthorizedEnvironment {
    func authorize(environment: Environment, sessionToken: SessionToken) {
        viewModel = ChannelViewModel(environment: environment,
                                     sessionToken: sessionToken)
    }
    
    var environment: Environment {
        return viewModel.environment
    }
    
    var sessionToken: SessionToken {
        return viewModel.sessionToken
    }
}


extension ChannelViewController: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        epgTableView.backgroundColor = brand.backdrop.primary
        view.backgroundColor = brand.backdrop.primary
    }
}
