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

class PlaybackPropertiesViewController: UITableViewController {

    @IBOutlet weak var programLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    
    var playbackProperties = PlaybackProperties()
    var program: Program?
    var timestampNow: Int64 = Date().millisecondsSince1970
    
    // MARK: - Start Time
    @IBOutlet weak var defaultBehaviourSwitch: UISwitch!
    @IBOutlet weak var beginningSwitch: UISwitch!
    @IBOutlet weak var useBookmarkSwitch: UISwitch!
    
    @IBOutlet weak var customOffsetLabel: UILabel!
    @IBOutlet weak var customOffsetSlider: UISlider!
    
    
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
        if let start = program?.startDate?.millisecondsSince1970, let end = program?.endDate?.millisecondsSince1970 {
            return transformOffset(start: start, end: end, sliderValue: sliderValue)
        }
        else {
            let start = timestampNow - 6 * 60 * 60 * 1000
            let end = timestampNow
            return transformOffset(start: start, end: end, sliderValue: sliderValue)
        }
    }
    
    func transformOffset(start: Int64, end: Int64, sliderValue: Float) -> Int64? {
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
    
    // MARK: - Language
    @IBOutlet weak var defaultLangSwitch: UISwitch!
    @IBOutlet weak var userLocaleSwitch: UISwitch!
    @IBOutlet weak var customLangSwitch: UISwitch!
    @IBOutlet weak var customLangTextField: UITextField!
    @IBOutlet weak var customLangAudioField: UITextField!
    
    @IBAction func defaultLangAction(_ sender: UISwitch) {
        if sender.isOn {
            userLocaleSwitch.isOn = false
            customLangSwitch.isOn = false
            customLangTextField.isEnabled = false
            customLangAudioField.isEnabled = false
        }
        else {
            userLocaleSwitch.isOn = true
            customLangSwitch.isOn = false
            customLangTextField.isEnabled = false
            customLangAudioField.isEnabled = false
        }
    }
    
    @IBAction func userLocaleAction(_ sender: UISwitch) {
        if sender.isOn {
            defaultLangSwitch.isOn = false
            customLangSwitch.isOn = false
            customLangTextField.isEnabled = false
            customLangAudioField.isEnabled = false
        }
        else {
            defaultLangSwitch.isOn = true
            userLocaleSwitch.isOn = false
            customLangSwitch.isOn = false
            customLangTextField.isEnabled = false
            customLangAudioField.isEnabled = false
        }
    }
    
    @IBAction func customLangAction(_ sender: UISwitch) {
        if sender.isOn {
            defaultLangSwitch.isOn = false
            userLocaleSwitch.isOn = false
            customLangSwitch.isOn = true
            customLangTextField.isEnabled = true
            customLangAudioField.isEnabled = true
        }
        else {
            defaultLangSwitch.isOn = true
            userLocaleSwitch.isOn = false
            customLangSwitch.isOn = false
            customLangTextField.isEnabled = false
            customLangAudioField.isEnabled = false
        }
    }
    
    func languageProperties() -> PlaybackProperties.LanguagePreferences {
        if defaultLangSwitch.isOn {
            return .defaultBehaviour
        }
        else if userLocaleSwitch.isOn {
            return .userLocale
        }
        else if customLangSwitch.isOn {
            return .custom(text: customLangTextField.text, audio: customLangAudioField.text)
        }
        else {
            return .defaultBehaviour
        }
    }
    
    // MARK: - Max Bitrate
    @IBOutlet weak var maxBitrateTextField: UITextField!
    @IBOutlet weak var maxBitrateSwitch: UISwitch!
    @IBAction func maxBitrateAction(_ sender: UISwitch) {
        maxBitrateTextField.isEnabled = sender.isOn
    }
    
    func maxBitrateProperties() -> Int64? {
        if maxBitrateSwitch.isOn, let text = maxBitrateTextField.text, let value = Int64(text) {
            return value * 1000
        }
        return nil
    }
    
    // MARK: - Execute
    var onDone: (PlaybackProperties) -> Void = { _ in }
    var onCancel: () -> Void = { _ in }
    
    @IBAction func doneAction(_ sender: UIButton) {
        let language = languageProperties()
        let maxBitrate = maxBitrateProperties()
        let props = PlaybackProperties(autoplay: playbackProperties.autoplay,
                                       playFrom: playbackProperties.playFrom,
                                       language: language,
                                       maxBitrate: maxBitrate)
        onDone(props)
    }
    @IBAction func cancelAction(_ sender: UIButton) {
        onCancel()
    }
    
    // MARK: - Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.keyboardDismissMode = .onDrag
        
        timestampNow = Date().millisecondsSince1970
        
        // Start Time
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
        
        // Language
        switch playbackProperties.language {
        case .defaultBehaviour:
            defaultLangSwitch.isOn = true
            customLangTextField.isEnabled = false
            customLangAudioField.isEnabled = false
        case .userLocale:
            userLocaleSwitch.isOn = true
            customLangTextField.isEnabled = false
            customLangAudioField.isEnabled = false
        case let .custom(text: text, audio: audio):
            customLangSwitch.isOn = true
            customLangTextField.isEnabled = true
            customLangTextField.text = text
            customLangAudioField.isEnabled = true
            customLangAudioField.text = audio
        }
        
        // Program Data
        programLabel.text = program?.programId ?? "Channel"
        startTimeLabel.text = program?.startDate?.dateString(format: "HH:mm") ?? "n/a"
        endTimeLabel.text = program?.endDate?.dateString(format: "HH:mm") ?? "n/a"
        
        // Bitrate Restrictions
        maxBitrateTextField.isEnabled = playbackProperties.maxBitrate != nil
        if let bitrate = playbackProperties.maxBitrate { maxBitrateTextField.text = String(bitrate/1000) }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
