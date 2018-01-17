//
//  TestEnvTimeshiftDelay.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2018-01-11.
//  Copyright © 2018 emp. All rights reserved.
//

import UIKit
import Exposure
import Player

class TestEnvTimeshiftDelay: UIViewController {
    var controls: TestEnvTimeshiftDelayControls!
    
    var environment: Environment!
    var sessionToken: SessionToken!
    
    var channel: Asset!
    var program: Program?
    
    @IBOutlet weak var playerView: UIView!
    fileprivate(set) var player: Player<HLSNative<ExposureContext>>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        player = Player(environment: environment, sessionToken: sessionToken)
        
        player.configure(playerView: playerView)
        
        controls.onTimeTick = { [weak self] in
            guard let `self` = self else { return }
            if let currentTime = self.player.serverTime {
                let date = Date(milliseconds: currentTime)
                self.controls.wallclockTimeLabel.text = date.dateString(format: "HH:mm:ss")
            }
            else {
                self.controls.wallclockTimeLabel.text = "n/a"
            }
            
//            self.player.tech.logStuff()
            
            let seekableRange = self.player.seekableRange.map{ ($0.start.seconds, $0.end.seconds) }.first
            let bufferedRange = self.player.bufferedRange.map{ ($0.start.seconds, $0.end.seconds) }.first
            if let seekable = seekableRange {
                self.controls.seekableStartLabel.text = String(Int64(seekable.0))
                self.controls.seekableEndLabel.text = String(Int64(seekable.1))
            }
            if let buffered = bufferedRange {
                self.controls.bufferedStartLabel.text = String(Int64(buffered.0))
                self.controls.bufferedEndLabel.text = String(Int64(buffered.1))
            }
            
            if let playheadTime = self.player.playheadTime {
                let date = Date(milliseconds: playheadTime)
                self.controls.playheadTimeLabel.text = date.dateString(format: "HH:mm:ss")
            }
            else {
                self.controls.playheadTimeLabel.text = "n/a"
            }
            
            self.controls.playheadPositionLabel.text = String(self.player.playheadPosition/1000)
        }
        
        player
            .autoplay(enabled: true)
            .onPlaybackReady{ [weak self] tech, source in
                guard let `self` = self else { return }
                self.controls.timeshiftDelayTextField.text = self.player.timeshiftDelay != nil ? String(self.player.timeshiftDelay!) : nil
                
                // Start updating playheadTime + playheadPosition
            }
            .onError{ [weak self] tech, source, error in
                guard let `self` = self else { return }
                self.showMessage(title: "Error \(error.code)", message: error.message)
        }
        
        guard let channelId = channel.assetId else {
            showMessage(title: "Playback start error", message: "No ChannelId")
            return
        }
        player.startPlayback(channelId: channelId, programId: program?.programId, useBookmark: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? TestEnvTimeshiftDelayControls, segue.identifier == "timeshiftControls" {
            controls = viewController
            
            viewController.onViewDidLoad = { [weak self, unowned viewController] in
                guard let `self` = self else { return }
                viewController.programIdLabel.text = self.program?.anyTitle(locale: "en") ?? self.channel.anyTitle(locale: "en")
                viewController.startTimeLabel.text = self.program?.startDate?.dateString(format: "HH:mm") ?? "n/a"
                viewController.endTimeLabel.text = self.program?.endDate?.dateString(format: "HH:mm") ?? "n/a"
            }
            
//            viewController.onTimeshifting = { [weak self] timeshiftDelay in
//                guard let `self` = self else { return }
//                self.player.timeshiftDelay = timeshiftDelay
//            }
            
            viewController.onSeeking = { [weak self] seekDelta in
                guard let `self` = self else { return }
                let currentPosition = self.player.playheadPosition
                self.player.seek(toPosition: currentPosition + seekDelta * 1000)
            }
            
            viewController.onPauseResumed = { [weak self] paused in
                guard let `self` = self else { return }
                if paused {
                    self.player.play()
                }
                else {
                    self.player.pause()
                }
            }
        }
    }
}
