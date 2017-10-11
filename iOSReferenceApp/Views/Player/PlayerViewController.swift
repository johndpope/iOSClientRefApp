//
//  PlayerViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-04-07.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import UIKit
import Player
import AVFoundation
import Exposure
import Analytics
import MediaPlayer

class PlayerViewController: UIViewController {
    
    fileprivate var player: Player = Player()
    var viewModel: PlayerViewModel!
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var playerView: UIView!
    
    @IBOutlet weak var pausePlayButton: UIButton!
    @IBOutlet weak var quickRewindButton: UIButton!
    @IBOutlet weak var timelineSlider: UISlider!
    @IBOutlet weak var quickFastForwardButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var airplayButton: MPVolumeView!
    
    fileprivate var timelineUpdater: Timer?
    
    var onDismissed: () -> Void = { _ in }
    
    override func viewDidLoad() {
        player.onError{ [unowned self] player, error in
            self.showMessage(title: "Player Error", message: error.localizedDescription)
        }
        
        player.onPlaybackCreated{ player in
            print("onPlaybackCreated")
        }
        
        player.onPlaybackPrepared{ player in
            print("onPlaybackPrepared")
        }
        
        player.onPlaybackReady{ player in
            print("onPlaybackReady")
            player.play()
        }
        
        player.onPlaybackStarted{ [unowned self] player in
            print("onPlaybackStarted")
            self.togglePlayPauseButton(paused: false)
        }
        
        player.onPlaybackPaused{ [unowned self] player in
            print("onPlaybackPaused")
            self.togglePlayPauseButton(paused: true)
        }
        
        player.onPlaybackResumed{ [unowned self] player in
            print("onPlaybackResumed")
            self.togglePlayPauseButton(paused: false)
        }
        
        player.onPlaybackCompleted{ player in
            print("onPlaybackCompleted")
        }
        
        player.onBitrateChanged{ event in
            print("onBitrateChanged",event)
        }
        
        player.onBufferingStarted{ event in
            print("onBufferingStarted",event)
        }
        
        player.onBufferingStopped{ event in
            print("onBufferingStopped",event)
        }
        
        player.onDurationChanged{ player in
            print("onDurationChanged",player.duration)
        }

        player.onPlaybackScrubbed { player, toTime in
            print("onPlaybackScrubbed", toTime)
        }
        
        if let playRequest = viewModel.playRequest {
            stream(playRequest: playRequest)
        }
        
        viewModel.onPlaybackRequested = { [unowned self] request in
            self.stream(playRequest: request)
        }
        
        startTimelineUpdate()
        
        // Enable airplay icon
        airplayButton.showsVolumeSlider = false
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        player.configure(playerView: playerView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopTimelineUpdate()
    }
    
    // MARK: Actions
    @IBAction func actionBack(_ sender: UIButton) {
        player.stop()
        dismiss(animated: true) { [weak self] in
            self?.onDismissed()
        }
    }
    
    @IBAction func actionPausePlay(_ sender: UIButton) {
        if player.isPlaying {
            player.pause()
        }
        else {
            player.play()
        }
    }
    
    @IBAction func actionQuickRewind(_ sender: UIButton) {
        let currentPosition = player.currentTime
        player.seek(to: currentPosition - 10 * 1000)
    }
    
    @IBAction func actionQuickForward(_ sender: UIButton) {
        let currentPosition = player.currentTime
        player.seek(to: currentPosition + 10 * 1000)
    }
    
    @IBAction func actionToggleOverlay(_ sender: UITapGestureRecognizer) {
        overlayView.isHidden = !overlayView.isHidden
    }
    
    @IBAction func actionUserScrubbing(_ sender: UISlider) {
        viewModel.isScrubbing = true
        updateTimeline(with: Int64(sender.value))
    }
    
    @IBAction func actionSeekTo(_ sender: UISlider) {
        viewModel.isScrubbing = false
        
        player.seek(to: Int64(timelineSlider.value))
        startTimelineUpdate()
    }
}

extension PlayerViewController {
    fileprivate func stream(playRequest: PlayerViewModel.PlayRequest) {
        switch playRequest {
        case .vod(assetId: let assetId): stream(vod: assetId)
        case .live(channelId: let channelId): stream(live: channelId)
        case .catchup(channelId: let channelId, programId: let programId): stream(program: programId, channel: channelId)
        case .offline(assetId: let assetId): offline(assetId: assetId)
        }
        
    }

    private func stream(vod assetId: String) {
        player
            .analytics(using: viewModel.sessionToken,
                       in: viewModel.environment)
            .sessionShift(enabled: true)
            .stream(vod: assetId) { [unowned self] entitlement, error in
                if let error = error {
                    self.showMessage(title: "Playback Error", message: error.localizedDescription)
                }
        }
    }
    
    private func stream(live channelId: String) {
        player
            .analytics(using: viewModel.sessionToken,
                       in: viewModel.environment)
            .stream(live: channelId) { [unowned self] entitlement, error in
                if let error = error {
                    // Workaround until EMP-10243 is fixed
                    if case let .exposure(error: .exposureResponse(reason: reason)) = error, (reason.httpCode == 403 && reason.message == "NOT_ENABLED") {
                        print("Workaround for EMP-10243 activated! - Testing vod endpoint")
                        self.player.stream(vod: channelId) { [unowned self] entitlement, error in
                            if let error = error {
                                self.showMessage(title: "Playback Error", message: error.localizedDescription)
                            }
                        }
                    }
                    else {
                        self.showMessage(title: "Playback Error", message: error.localizedDescription)
                    }
                }
        }
    }
    
    private func stream(program programId: String, channel channelId: String) {
        player
            .analytics(using: viewModel.sessionToken,
                       in: viewModel.environment)
            .sessionShift(enabled: true)
            .stream(programId: programId, channelId: channelId) { [unowned self] entitlement, error in
                if let error = error {
                    self.showMessage(title: "Playback Error", message: error.localizedDescription)
                }
        }
    }
    
    private func offline(assetId: String) {
        guard let offline = OfflineAssetTracker.offline(assetId: assetId) else {
            self.showMessage(title: "Offline Playback Error", message: "No local media found for \(assetId)")
            return
        }
        
        guard let urlAsset = offline.urlAsset else {
            self.showMessage(title: "Offline Playback Error", message: "Local media for \(assetId) has no url")
            return
        }
        player.offline(entitlement: offline.entitlement, assetId: offline.assetId, urlAsset: urlAsset)
    }
}

extension PlayerViewController {
    fileprivate func startTimelineUpdate() {
        stopTimelineUpdate()
        timelineUpdater = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(PlayerViewController.timedTimelineUpdate), userInfo: nil, repeats: true)
    }
    
    fileprivate func stopTimelineUpdate() {
        guard let timer = timelineUpdater, timer.isValid else { return }
        timer.invalidate()
        timelineUpdater = nil
    }
    
    @objc fileprivate func timedTimelineUpdate() {
        guard !viewModel.isScrubbing else { return }
        
        let currentTime = player.currentTime
        updateTimeline(with: currentTime)
    }
    
    fileprivate func updateTimeline(with currentTime: Int64) {
        if let duration = player.duration {
            // Calculate time remaining
            timelineSlider.isHidden = false
            
            if timelineSlider.maximumValue < Float(duration) { timelineSlider.maximumValue = Float(duration) }
            timelineSlider.setValue(Float(currentTime), animated: true)
            
            timeLabel.text = viewModel.timeFormat(time: currentTime - duration)
        }
        else {
            // No duration available, perhaps because this is a live broadcast.
            // Set time to current position
            timelineSlider.isHidden = true
            timeLabel.text = viewModel.timeFormat(time: currentTime)
        }
    }
}

extension PlayerViewController {
    fileprivate func togglePlayPauseButton(paused: Bool) {
        if !paused {
            pausePlayButton.setImage(#imageLiteral(resourceName: "overlay-pause"), for: UIControlState.normal)
        }
        else {
            pausePlayButton.setImage(#imageLiteral(resourceName: "overlay-play"), for: UIControlState.normal)
        }
    }
}
