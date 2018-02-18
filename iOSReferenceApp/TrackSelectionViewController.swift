//
//  TrackSelectionViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2018-02-08.
//  Copyright © 2018 emp. All rights reserved.
//

import UIKit
import Player

class TrackSelectionViewModel {
    let mediaTrack: MediaTrack?
    
    init(mediaTrack: MediaTrack?) {
        self.mediaTrack = mediaTrack
    }
    
    var displayName: String {
        return mediaTrack?.name ?? "Off"
    }
}

class TrackSelectionViewController: UIViewController {

    @IBOutlet weak var audioTableView: UITableView!
    @IBOutlet weak var textTableView: UITableView!
    
    
    var selectedAudio: IndexPath? = nil
    var selectedText: IndexPath? = nil
    var audioViewModels: [TrackSelectionViewModel] = []
    var textViewModels: [TrackSelectionViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        audioTableView.reloadData()
        textTableView.reloadData()
    }
    
    func assign(audio: MediaGroup?) {
        audioViewModels = prepareViewModels(for: audio)
        selectedAudio = (0..<audioViewModels.count).flatMap { index -> IndexPath? in
            let vm = audioViewModels[index]
            if audio?.selectedTrack == vm.mediaTrack {
                return IndexPath(row: index, section: 0)
            }
            return nil
        }.last
    }
    
    func assign(text: MediaGroup?) {
        textViewModels = prepareViewModels(for: text)
        selectedText = (0..<textViewModels.count).flatMap { index -> IndexPath? in
            let vm = textViewModels[index]
            if text?.selectedTrack == vm.mediaTrack {
                return IndexPath(row: index, section: 0)
            }
            return nil
        }.last
    }
    
    private func prepareViewModels(for mediaGroup: MediaGroup?) -> [TrackSelectionViewModel] {
        guard let mediaGroup = mediaGroup else { return [] }
        var vms = mediaGroup.tracks.map{ TrackSelectionViewModel(mediaTrack: $0) }
        
        if mediaGroup.allowsEmptySelection {
            let off = TrackSelectionViewModel(mediaTrack: nil)
            vms.append(off)
        }
        return vms
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    var onDidSelectAudio: (MediaTrack?) -> Void = { _ in }
    var onDidSelectText: (MediaTrack?) -> Void = { _ in }
    var onDismissed: () -> Void = { }
    
    @IBAction func dismissAction(_ sender: UIButton) {
        onDismissed()
    }
}

extension TrackSelectionViewController: UITableViewDelegate {
    fileprivate func viewModels(for tableView: UITableView) -> [TrackSelectionViewModel] {
        if tableView == audioTableView {
            return audioViewModels
        }
        else if tableView == textTableView {
            return textViewModels
        }
        return []
    }
    fileprivate func selectedIndexPath(for tableView: UITableView) -> IndexPath? {
        if tableView == audioTableView {
            return selectedAudio
        }
        else if tableView == textTableView {
            return selectedText
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let track = viewModels(for: tableView)[indexPath.row]
        
        
        cell.textLabel?.text = track.displayName
        cell.accessoryType = selectedIndexPath(for: tableView) == indexPath ? .checkmark : .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        if let currentlySelected = selectedIndexPath(for: tableView) {
            tableView.cellForRow(at: currentlySelected)?.accessoryType = .none
        }
        
        
        if tableView == audioTableView {
            selectedAudio = indexPath
            onDidSelectAudio(viewModels(for: tableView)[indexPath.row].mediaTrack)
        }
        else if tableView == textTableView {
            selectedText = indexPath
            onDidSelectText(viewModels(for: tableView)[indexPath.row].mediaTrack)
        }
    }
}

extension TrackSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels(for: tableView).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    }
    
    
}
