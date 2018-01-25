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
            
            self.player.timeBehindLive
            #if DEBUG
//            self.player.tech.logStuff()
            #endif
                
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
                tech.play()
                // Start updating playheadTime + playheadPosition
            }
            .onError{ [weak self] tech, source, error in
                guard let `self` = self else { return }
                self.showMessage(title: "Error \(error.code)", message: error.message)
            }
            .onProgramChanged{ [weak self] tech, source, program in
                guard let `self` = self else { return }
                print("onProgramChanged",program?.programId)
                self.update(withProgram: program)
        }
        
        if let programId = program?.programId {
            player.startPlayback(channelId: channel.assetId, programId: programId)
        }
        else {
            player.startPlayback(channelId: channel.assetId)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? TestEnvTimeshiftDelayControls, segue.identifier == "timeshiftControls" {
            controls = viewController
            
            viewController.onSeeking = { [weak self] seekDelta in
                guard let `self` = self else { return }
                let currentTime = self.player.playheadPosition
                self.player.seek(toPosition: currentTime + seekDelta * 1000)
            }
            
            viewController.onSeekingTime = { [weak self] seekDelta in
                guard let `self` = self else { return }
                if let currentTime = self.player.playheadTime {
                    self.player.seek(toTime: currentTime + seekDelta * 1000)
                }
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
            
            viewController.onStartOver = { [weak self] in
                if let programStartTime = self?.player.currentProgram?.startDate?.millisecondsSince1970 {
                    self?.player.seek(toTime: programStartTime)
                }
            }
            
            viewController.onGoLive = { [weak self] in
                guard let `self` = self else { return }
                let serverTime = self.player.serverTime ?? Date().millisecondsSince1970
                self.player.seek(toTime: serverTime)
            }
            
            
        }
    }
    
    func update(withProgram program: Program?) {
        controls.programIdLabel.text = program?.anyTitle(locale: "en") ?? self.channel.anyTitle(locale: "en")
        controls.startTimeLabel.text = program?.startDate?.dateString(format: "HH:mm") ?? "n/a"
        controls.endTimeLabel.text = program?.endDate?.dateString(format: "HH:mm") ?? "n/a"
    }
}