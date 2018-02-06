//
//  PlaybackPropertiesViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2018-02-02.
//  Copyright © 2018 emp. All rights reserved.
//

import UIKit
import ExposurePlayback
import Exposure

class PlaybackPropertiesViewController: UIViewController {

    @IBOutlet weak var defaultBehaviourSwitch: UISwitch!
    @IBOutlet weak var beginningSwitch: UISwitch!
    @IBOutlet weak var useBookmarkSwitch: UISwitch!
    
    @IBOutlet weak var customOffsetLabel: UILabel!
    @IBOutlet weak var customOffsetSlider: UISlider!
    
    @IBOutlet weak var programLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    
    var playbackProperties = PlaybackProperties()
    var program: Program?
    var onDone: (PlaybackProperties) -> Void = { _ in }
    var onCancel: () -> Void = { _ in }
    
    @IBAction func defaultBehaviourAction(_ sender: UISwitch) {
        if sender.isOn {
            toggle(playFrom: .defaultBehaviour)
            beginningSwitch.isOn = false
            useBookmarkSwitch.isOn = false
            customOffsetSlider.minimumTrackTintColor = UIColor.darkGray
        }
        else {
            toggle(playFrom: .beginning)
            defaultBehaviourSwitch.isOn = false
            beginningSwitch.isOn = true
            useBookmarkSwitch.isOn = false
            customOffsetSlider.minimumTrackTintColor = UIColor.darkGray
        }
    }
    @IBAction func fromBeginningAction(_ sender: UISwitch) {
        if sender.isOn {
            toggle(playFrom: .beginning)
            defaultBehaviourSwitch.isOn = false
            useBookmarkSwitch.isOn = false
            customOffsetSlider.minimumTrackTintColor = UIColor.darkGray
        }
        else {
            toggle(playFrom: .defaultBehaviour)
            defaultBehaviourSwitch.isOn = true
            beginningSwitch.isOn = false
            useBookmarkSwitch.isOn = false
            customOffsetSlider.minimumTrackTintColor = UIColor.darkGray
        }
    }
    @IBAction func fromBookmarkAction(_ sender: UISwitch) {
        if sender.isOn {
            toggle(playFrom: .bookmark)
            defaultBehaviourSwitch.isOn = false
            beginningSwitch.isOn = false
            customOffsetSlider.minimumTrackTintColor = UIColor.darkGray
        }
        else {
            toggle(playFrom: .defaultBehaviour)
            defaultBehaviourSwitch.isOn = true
            beginningSwitch.isOn = false
            useBookmarkSwitch.isOn = false
            customOffsetSlider.minimumTrackTintColor = UIColor.darkGray
        }
    }
    
    @IBAction func customOffsetAction(_ sender: UISlider) {
        defaultBehaviourSwitch.isOn = false
        beginningSwitch.isOn = false
        useBookmarkSwitch.isOn = false
        
        customOffsetSlider.minimumTrackTintColor = UIColor.green
        
        guard let value = transformOffset(sliderValue: sender.value) else {
            customOffsetSlider.minimumTrackTintColor = UIColor.darkGray
            return
        }
        
        customOffsetLabel.text = Date(milliseconds: value).dateString(format: "HH:mm:ss")
        toggle(playFrom: .customTime(timestamp: value))
    }
    
    func toggle(playFrom: PlaybackProperties.PlayFrom) {
        playbackProperties = PlaybackProperties(autoplay: playbackProperties.autoplay, playFrom: playFrom)
    }
    
    func transformOffset(sliderValue: Float) -> Int64? {
        guard let start = program?.startDate?.millisecondsSince1970, let end = program?.endDate?.millisecondsSince1970 else {
            return nil
        }
        let value = Double(sliderValue)
        let hour: Double = 60 * 60 * 1000
        if value < 0.2 {
            // Force negative out-of-bounds offset
            customOffsetLabel.textColor = UIColor.red
            return start - Int64(hour - hour * (value / 0.2))
        }
        else if value > 0.8 {
            // Force positive out-of-bounds offset
            customOffsetLabel.textColor = UIColor.red
            return end + Int64(hour - hour * (1-value) / 0.2)
        }
        else {
            customOffsetLabel.textColor = UIColor.black
            let durationPercentage = Double(end - start) * (value-0.2)/(0.8-0.2)
            let offset = start + Int64(durationPercentage)
            return offset
        }
    }
    
    @IBAction func doneAction(_ sender: UIButton) {
        onDone(playbackProperties)
    }
    @IBAction func cancelAction(_ sender: UIButton) {
        onCancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        switch playbackProperties.playFrom {
        case .defaultBehaviour:
            defaultBehaviourSwitch.isOn = true
        case .beginning:
            beginningSwitch.isOn = true
        case .bookmark:
            useBookmarkSwitch.isOn = true
        case .customTime(timestamp: let offset):
            customOffsetLabel.text = Date(milliseconds: offset).dateString(format: "HH:mm:ss")
            if let start = program?.startDate?.millisecondsSince1970, let end = program?.endDate?.millisecondsSince1970 {
                if offset < start || offset > end {
                    customOffsetLabel.textColor = UIColor.red
                }
            }
        case .customPosition(position: _):
            return
        }
        
        programLabel.text = program?.anyTitle(locale: "en") ?? "Channel"
        startTimeLabel.text = program?.startDate?.dateString(format: "HH:mm") ?? "n/a"
        endTimeLabel.text = program?.endDate?.dateString(format: "HH:mm") ?? "n/a"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
