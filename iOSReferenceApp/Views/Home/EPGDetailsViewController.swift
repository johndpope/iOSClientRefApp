//
//  EPGDetailsViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-07-10.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Kingfisher
import Exposure

class EPGDetailsViewController: UIViewController {

    
    @IBOutlet weak var channelTitleLabel: UIButton!
    @IBOutlet weak var epgTableView: UITableView!
    
    fileprivate(set) var viewModel: EPGDetailsViewModel!
    fileprivate weak var playerViewModel: PlayerViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.hidesBackButton = true
        
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -15)
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont(name: "Helvetica", size: 12)!,
             //             NSForegroundColorAttributeName: UIColor.white
            ],
            for: UIControlState.normal)
        
        epgTableView.delegate = self
        epgTableView.dataSource = self
        
        epgTableView.register(UINib(nibName: "EPGPreviewCell", bundle: nil),
                              forCellReuseIdentifier: "EPGPreviewCell")
        
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollToLive(animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func bind(viewModel: EPGDetailsViewModel) {
        self.viewModel = viewModel
    }
    
    
    @IBAction func actionChannelTitle(_ sender: UIButton) {
        scrollToLive(animated: true)
    }
}

extension EPGDetailsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embeddedPlayerView" {
            if let destination = segue.destination as? PlayerViewController {
                destination.viewModel = PlayerViewModel(sessionToken: viewModel.sessionToken,
                                                        environment: viewModel.environment)
                playerViewModel = destination.viewModel
            }
        }
    }
}

extension EPGDetailsViewController {
    
}

extension EPGDetailsViewController:  UITableViewDelegate {
    
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

extension EPGDetailsViewController: UITableViewDataSource {
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
        }
    }
}

extension EPGDetailsViewController {
    fileprivate func setupViewModel() {
        channelTitleLabel.setTitle(viewModel.anyTitle(locale: "en"), for: [])
        
        let current = Date()
        viewModel.fetchEPG(starting: current.subtract(days: 1), ending: current.add(days: 1) ?? current) { [unowned self] error in
            if let error = error {
                self.showMessage(title: "EPG Error", message: error.localizedDescription)
            }
            else {
                self.epgTableView.reloadData()
                self.scrollToLive(animated: true)
            }
        }
        
        playerViewModel?.request(playback: .live(channelId: viewModel.channelId))
    }
}

extension EPGDetailsViewController {
    func scrollToLive(animated: Bool) {
        guard let liveRow = viewModel.currentlyLive() else { return }
        epgTableView.scrollToRow(at: liveRow, at: .middle, animated: animated)
    }
}

extension EPGDetailsViewController: AuthorizedEnvironment {
    var environment: Environment {
        return viewModel.environment
    }
    
    var sessionToken: SessionToken {
        return viewModel.sessionToken
    }
}
