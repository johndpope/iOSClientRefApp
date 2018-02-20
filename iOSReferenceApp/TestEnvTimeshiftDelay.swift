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
import ExposurePlayback

class TestEnvTimeshiftDelay: UIViewController {
    var controls: TestEnvTimeshiftDelayControls!
    
    var environment: Environment!
    var sessionToken: SessionToken!
    
    var channel: Asset!
    var program: Program?
    var playbackProperties = PlaybackProperties(playFrom: PlaybackProperties.PlayFrom.bookmark)
    
    @IBOutlet weak var playerView: UIView!
    fileprivate(set) var player: Player<HLSNative<ExposureContext>>!
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        ToastManager.shared.position = .top
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
            
            #if DEBUG
//            self.player.tech.logStuff()
            #endif
            
            let seekableRange = self.player.seekableRanges.map{ ($0.start.seconds, $0.end.seconds) }.first
            let bufferedRange = self.player.bufferedRanges.map{ ($0.start.seconds, $0.end.seconds) }.first
            if let seekable = seekableRange {
                self.controls.seekableStartLabel.text = String(Int64(seekable.0))
                self.controls.seekableEndLabel.text = String(Int64(seekable.1))
            }
            if let buffered = bufferedRange {
                self.controls.bufferedStartLabel.text = String(Int64(buffered.0))
                self.controls.bufferedEndLabel.text = String(Int64(buffered.1))
            }
            
            let seekableTimeRange = self.player.seekableTimeRanges.first
            let bufferedTimeRange = self.player.bufferedTimeRanges.first
            if let seekableTime = seekableTimeRange, let start = seekableTime.start.milliseconds, let end = seekableTime.end.milliseconds {
                let start = Date(milliseconds: start).dateString(format: "HH:mm:ss")
                let end = Date(milliseconds: end).dateString(format: "HH:mm:ss")
                self.controls.seekableStartTimeLabel.text = start
                self.controls.seekableEndTimeLabel.text = end
            }
            if let bufferedTime = bufferedTimeRange, let start = bufferedTime.start.milliseconds, let end = bufferedTime.end.milliseconds  {
                let start = Date(milliseconds: start).dateString(format: "HH:mm:ss")
                let end = Date(milliseconds: end).dateString(format: "HH:mm:ss")
                self.controls.bufferedStartTimeLabel.text = start
                self.controls.bufferedEndTimeLabel.text = end
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
            .onError{ [weak self] player, source, error in
                guard let `self` = self else { return }
                self.showMessage(title: "Error \(error.code)", message: error.message)
            }
            .onProgramChanged{ [weak self] player, source, program in
                guard let `self` = self else { return }
                print("onProgramChanged",program?.programId)
                self.update(withProgram: program)
            }
            .onEntitlementResponse { [weak self] player, source, entitlement in
                guard let `self` = self else { return }
                self.update(contractRestrictions: entitlement)
            }
            .onWarning{ [weak self] player, source, warning in
                self?.view.makeToast(warning.message, duration: 5)
        }
        
        startPlayback(properties: playbackProperties)
    }

    func startPlayback(properties: PlaybackProperties) {
        if let program = program {
            player.startPlayback(playable: program.programPlayable, properties: properties)
        }
        else {
            player.startPlayback(playable: channel.channelPlayable, properties: properties)
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
            
            viewController.onCC = { [weak self] in
                guard let `self` = self else { return }
                let storyBoard = UIStoryboard(name: "TestEnv", bundle: nil)
                let ccViewController = storyBoard.instantiateViewController(withIdentifier: "TrackSelectionViewController") as! TrackSelectionViewController
                ccViewController.assign(audio: self.player.tech.audioGroup)
                ccViewController.assign(text: self.player.tech.textGroup)
                ccViewController.onDidSelectAudio = { [weak self] track in
                    guard let `self` = self else { return }
                    self.player.tech.selectAudio(track: track)
                }
                ccViewController.onDidSelectText = { [weak self] track in
                    guard let `self` = self else { return }
                    self.player.tech.selectText(track: track)
                }
                ccViewController.onDismissed = { [weak ccViewController] in
                    ccViewController?.dismiss(animated: true)
                }
                self.present(ccViewController, animated: true)
            }
            
            viewController.onGoLive = { [weak self] in
                guard let `self` = self else { return }
                self.player.seekToLive()
            }
            
            viewController.onReload = { [weak self] in
                guard let `self` = self else { return }
                let storyBoard = UIStoryboard(name: "TestEnv", bundle: nil)
                let propertiesViewController = storyBoard.instantiateViewController(withIdentifier: "PlaybackPropertiesViewController") as! PlaybackPropertiesViewController
                propertiesViewController.playbackProperties = self.playbackProperties
                propertiesViewController.program = self.program
                propertiesViewController.onDone = { [weak propertiesViewController, weak self] props in
                    propertiesViewController?.dismiss(animated: true)
                    self?.playbackProperties = props
                    self?.startPlayback(properties: props)
                }
                propertiesViewController.onCancel = { [weak propertiesViewController] in
                    propertiesViewController?.dismiss(animated: true)
                }
                self.present(propertiesViewController, animated: true)
            }
        }
    }
    
    func update(withProgram program: Program?) {
        self.program = program
        controls.programIdLabel.text = program?.programId ?? self.channel.assetId
        controls.startTimeLabel.text = program?.startDate?.dateString(format: "HH:mm") ?? "n/a"
        controls.endTimeLabel.text = program?.endDate?.dateString(format: "HH:mm") ?? "n/a"
    }
    
    func update(contractRestrictions entitlement: PlaybackEntitlement) {
        controls.ffEnabledLabel.text = entitlement.ffEnabled ? "FF enabled" : "FF disabled"
        controls.ffEnabledLabel.textColor = entitlement.ffEnabled ? UIColor.green : UIColor.red
        
        controls.rwEnabledLabel.text = entitlement.rwEnabled ? "RW enabled" : "RW disabled"
        controls.rwEnabledLabel.textColor = entitlement.rwEnabled ? UIColor.green : UIColor.red
        
        controls.timeshiftEnabledLabel.text = entitlement.timeshiftEnabled ? "Timeshift enabled" : "Timeshift disabled"
        controls.timeshiftEnabledLabel.textColor = entitlement.timeshiftEnabled ? UIColor.green : UIColor.red
    }
}
