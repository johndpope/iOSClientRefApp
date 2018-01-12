//
//  EpgViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure

class EpgViewController: UIViewController {

    var didSelectEpg: (_ program: String?, _ channel: String, _ metaData: Asset?) -> Void = { _,_,_ in }
    var brand: Branding.ColorScheme = Branding.ColorScheme.default
    
    var nowPlayingIndex: Int?
    @IBOutlet weak var epgTableView: UITableView!
    @IBOutlet weak var topContentInset: NSLayoutConstraint!
    
    fileprivate(set) var viewModel: ChannelViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        epgTableView.delegate = self
        epgTableView.dataSource = self
        
        epgTableView.register(UINib(nibName: "EPGPreviewCell", bundle: nil),
                              forCellReuseIdentifier: "EPGPreviewCell")
        epgTableView.register(UINib(nibName: "EpgUnavailableCell", bundle: nil),
                              forCellReuseIdentifier: "EpgUnavailableCell")
        
        prepareEpg()
        apply(brand: brand)
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func prepareEpg() {
        let current = Date()
        viewModel.fetchEPG(starting: current.subtract(days: 1), ending: current.add(days: 1) ?? current) { [weak self] error in
            if let error = error {
                self?.showMessage(title: "EPG Error", message: error.message)
            }
            else {
                self?.epgTableView.reloadData()
                self?.scrollToLiveOrActive(animated: true)
            }
        }
    }
}

extension EpgViewController {
    func mark(index: Int?, playing: Bool) {
        defer { nowPlayingIndex = index }
        
        if let previouslySelected = nowPlayingIndex, let cell = epgTableView.cellForRow(at: IndexPath(row: previouslySelected, section: 0)) as? EPGPreviewCell {
            cell.markAs(playing: false)
        }
        
        if let startingIndex = index, let cell = epgTableView.cellForRow(at: IndexPath(row: startingIndex, section: 0)) as? EPGPreviewCell {
            cell.markAs(playing: playing)
        }
    }
}

extension EpgViewController {
    func scrollToLiveOrActive(animated: Bool) {
        if let active = nowPlayingIndex {
            epgTableView.scrollToRow(at: IndexPath(row: active, section: 0), at: .middle, animated: animated)
            return
        }
        guard let liveRow = viewModel.currentlyLive() else { return }
        epgTableView.scrollToRow(at: liveRow, at: .middle, animated: animated)
    }
}

extension EpgViewController:  UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.rowHeight(index: indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if viewModel.epgAvailable {
            return !viewModel.content[indexPath.row].isUpcoming
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if viewModel.epgAvailable {
            let program = viewModel.content[indexPath.row].model
            guard let programId = viewModel.content[indexPath.row].model.assetId else { return }
            didSelectEpg(programId, viewModel.channelId, program.asset)
            mark(index: indexPath.row, playing: true)
        }
        else {
            didSelectEpg(nil, viewModel.channelId, viewModel.asset)
        }
    }
}

extension EpgViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.epgAvailable ? viewModel.content.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.epgAvailable {
             return tableView.dequeueReusableCell(withIdentifier: "EPGPreviewCell", for: indexPath)
        }
        else {
            return tableView.dequeueReusableCell(withIdentifier: "EpgUnavailableCell", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let preview = cell as? EPGPreviewCell {
            let vm = viewModel.content[indexPath.row]
            
            preview.reset()
            preview.bind(viewModel: vm)
            preview.apply(brand: brand)
            preview.markAs(playing: indexPath.row == nowPlayingIndex)
        }
    }
}

extension EpgViewController: AuthorizedEnvironment {
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


extension EpgViewController: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        epgTableView.backgroundColor = brand.backdrop.primary
        view.backgroundColor = brand.backdrop.primary
    }
}
