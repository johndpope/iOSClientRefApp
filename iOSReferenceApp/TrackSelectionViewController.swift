//
//  TrackSelectionViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2018-02-08.
//  Copyright © 2018 emp. All rights reserved.
//

import UIKit
import Player

class TrackSelectionViewController: UIViewController {

    @IBOutlet weak var audioTableView: UITableView!
    @IBOutlet weak var textTableView: UITableView!
    
    var textGroup: MediaGroup?
    var audioGroup: MediaGroup?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension TrackSelectionViewController: UITableViewDelegate {
    fileprivate func mediaGroup(for tableView: UITableView) -> MediaGroup? {
        if tableView == audioTableView {
            return audioGroup
        }
        else if tableView == textTableView {
            return textGroup
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let track = mediaGroup(for: tableView)?.tracks[indexPath.row]
        
        
        cell.textLabel?.text = track?.name ?? "n/a"
        if let selectedTrack = mediaGroup(for: tableView)?.selectedTrack, track == selectedTrack {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
    }
}

extension TrackSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaGroup(for: tableView)?.tracks.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    }
    
    
}
