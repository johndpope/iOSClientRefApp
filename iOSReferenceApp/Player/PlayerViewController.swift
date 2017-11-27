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
import Download
import AVFoundation
import Exposure
import Analytics
import MediaPlayer

class PlayerViewController: UIViewController {
    
    var brand: Branding.ColorScheme = Branding.ColorScheme.default
    fileprivate(set) var player: Player<HLSNative<ExposureContext>>!
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
        player = Player(environment: viewModel.environment,
                        sessionToken: viewModel.sessionToken,
                        analytics: ExposureAnalytics.self)
        player.context.analyticsGenerators.append({ _ in return AnalyticsLogger() })
        player
            .onError{ [unowned self] tech, source, error in
                self.showMessage(title: "Player Error", message: error.localizedDescription + "\n Code: \(error.code)")
            }
            .onPlaybackReady{ tech, source in
                tech.play()
            }
            .onPlaybackStarted{ [unowned self] tech, source in
                self.togglePlayPauseButton(paused: false)
            }
            .onPlaybackPaused{ [unowned self] tech, source in
                self.togglePlayPauseButton(paused: true)
            }
            .onPlaybackResumed{ [unowned self] tech, source in
                self.togglePlayPauseButton(paused: false)
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
        apply(brand: brand)
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
        case .program(programId: let programId, channelId: let channelId): stream(program: programId, channel: channelId)
        case .offline(assetId: let assetId): offline(assetId: assetId)
        }
        
    }

    private func stream(vod assetId: String) {
        player
//            .analytics(using: viewModel.sessionToken,
//                       in: viewModel.environment)
            .sessionShift(enabled: true)
            .stream(vod: assetId)
    }
    
    private func stream(live channelId: String) {
        player
//            .analytics(using: viewModel.sessionToken,
//                       in: viewModel.environment)
            .stream(live: channelId)
    }
    
    private func stream(program programId: String, channel channelId: String) {
        player
//            .analytics(using: viewModel.sessionToken,
//                       in: viewModel.environment)
            .sessionShift(enabled: true)
            .stream(programId: programId,
                    channelId: channelId)
    }
    
    private func offline(assetId: String) {
        guard let offline = ExposureSessionManager
            .shared
            .manager
            .offline(assetId: assetId) else {
            self.showMessage(title: "Offline Playback Error", message: "No local media found for \(assetId)")
            return
        }

        guard let urlAsset = offline.urlAsset else {
            self.showMessage(title: "Offline Playback Error", message: "Local media for \(assetId) has no url")
            return
        }
        
        guard let entitlement = offline.entitlement else {
            self.showMessage(title: "Offline Playback Error", message: "No entitlement found for local media \(assetId)")
            return
        }
        player.offline(entitlement: entitlement, assetId: offline.assetId, urlAsset: urlAsset)
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


extension PlayerViewController: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        view.backgroundColor = brand.backdrop.primary
        timelineSlider.apply(brand: brand)
        timeLabel.textColor = brand.text.primary
    }
}
