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
import Cast
import GoogleCast

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
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var airplayButton: MPVolumeView!
    @IBOutlet weak var castButtonContainer: UIStackView!
    @IBOutlet weak var castButton: GCKUICastButton!
    var onChromeCastRequested: (PlayerViewModel.PlayRequest, Int64) -> Void = { _,_ in }
    
    fileprivate var timelineUpdater: Timer?
    var onDismissed: () -> Void = { _ in }
    
    var presentationMode: Mode = .standalone
    enum Mode {
        case standalone
        case embedded
    }
    
    override func viewDidLoad() {
        player = Player(environment: viewModel.environment,
                        sessionToken: viewModel.sessionToken)
        player.context.analyticsGenerators.append({ _ in return AnalyticsLogger() })
        player
            .onError{ [weak self] player, source, error in
                self?.showMessage(title: "Player Error", message: error.message + "\n Code: \(error.code)")
            }
            .onPlaybackReady{ player, source in
                player.play()
            }
            .onPlaybackStarted{ [weak self] player, source in
                self?.togglePlayPauseButton(paused: false)
                self?.startTimelineUpdate()
            }
            .onPlaybackPaused{ [weak self] player, source in
                self?.togglePlayPauseButton(paused: true)
            }
            .onPlaybackResumed{ [weak self] player, source in
                self?.togglePlayPauseButton(paused: false)
            }
            .onPlaybackAborted { [weak self] player, source in
                self?.hideTimeline()
        }
        
        if let playRequest = viewModel.playRequest {
            stream(playRequest: playRequest)
        }
        
        viewModel.onPlaybackRequested = { [unowned self] request in
            self.stream(playRequest: request)
        }
        
        startTimelineUpdate()
        
        // Listen to sessions
        GCKCastContext.sharedInstance().sessionManager.add(self)
        
        // Enable airplay icon
        airplayButton.showsVolumeSlider = false
        
        configure(for: presentationMode)
    }
    
    func configure(for presentationMode: Mode) {
        switch presentationMode {
        case .standalone:
            castButtonContainer.isHidden = false
            backButton.isHidden = false
        case .embedded:
            /// Due to GoogleCast framework internals, hiding the actual `GCKUICastButton` does not allways work. We have to resort to hiding the *container* instead
            castButtonContainer.isHidden = true
            backButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configure(for: presentationMode)
        player.configure(playerView: playerView)
        apply(brand: brand)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopTimelineUpdate()
    }
}

extension PlayerViewController {
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
        let currentPosition = player.playheadPosition
        player.seek(toPosition: currentPosition - 10 * 1000)
    }
    
    @IBAction func actionQuickForward(_ sender: UIButton) {
        let currentPosition = player.playheadPosition
        player.seek(toPosition: currentPosition + 10 * 1000)
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
        
        player.seek(toPosition: Int64(timelineSlider.value))
        startTimelineUpdate()
    }
}

extension PlayerViewController {
    fileprivate func stream(playRequest: PlayerViewModel.PlayRequest) {
        switch playRequest {
        case .vod(assetId: let assetId, metaData: let metaData): stream(vod: assetId, metaData: metaData)
        case .live(channelId: let channelId, metaData: let metaData): stream(live: channelId, metaData: metaData)
        case .program(programId: let programId, channelId: let channelId, metaData: let metaData): stream(program: programId, channel: channelId, metaData: metaData)
        case .offline(assetId: let assetId, metaData: let metaData): offline(assetId: assetId, metaData: metaData)
        }
        
    }
    
    private func stream(vod assetId: String, metaData: Asset?) {
        player.startPlayback(assetId: assetId)
    }
    
    private func stream(live channelId: String, metaData: Asset?) {
        player.startPlayback(channelId: channelId)
    }
    
    private func stream(program programId: String, channel channelId: String, metaData: Asset?) {
        player.startPlayback(channelId: channelId, programId: programId)
    }
    
    private func offline(assetId: String, metaData: Asset?) {
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
        
        let currentTime = player.playheadPosition
        updateTimeline(with: currentTime)
    }
    
    fileprivate func hideTimeline() {
        timelineSlider.isHidden = true
        timeLabel.text = ""
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
        castButton.apply(brand: brand)
    }
}


extension PlayerViewController: GCKSessionManagerListener {
    func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKSession) {
        print("willStart GCKSession")
    }
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        print("didStart GCKSession")
        sessionManager.remove(self)
        
        // HACK: Instruct the relevant analyticsProviders that startCasting event took place
        // TODO: We do not have nor want a strong coupling between the Cast and Player framework.
        player.tech.currentSource?.analyticsConnector.providers
            .flatMap{ $0 as? ExposureAnalytics }
            .forEach{ $0.startedCasting() }
        let currentTime = player.tech.playheadPosition
        player.stop()
        
        
        guard let request = viewModel.playRequest else { return }
        onChromeCastRequested(request, currentTime)
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKSession, withError error: Error?) {
        
    }
    func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
        print("willStart GCKCastSession")
        
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        print("Cast.Channel connected")
        
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKCastSession) {
        print("Cast.Channel disconnected")
        
    }
}
