//
//  TestEnvTimeshiftDelayControls.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2018-01-14.
//  Copyright © 2018 emp. All rights reserved.
//

import UIKit

class TestEnvTimeshiftDelayControls: UITableViewController {
    
    @IBOutlet weak var programIdLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var seekableStartLabel: UILabel!
    @IBOutlet weak var seekableEndLabel: UILabel!
    @IBOutlet weak var bufferedStartLabel: UILabel!
    @IBOutlet weak var bufferedEndLabel: UILabel!
    
    @IBOutlet weak var seekableStartTimeLabel: UILabel!
    @IBOutlet weak var seekableEndTimeLabel: UILabel!
    @IBOutlet weak var bufferedStartTimeLabel: UILabel!
    @IBOutlet weak var bufferedEndTimeLabel: UILabel!
    
    @IBOutlet weak var wallclockTimeLabel: UILabel!
    @IBOutlet weak var playheadTimeLabel: UILabel!
    @IBOutlet weak var playheadPositionLabel: UILabel!
    
    @IBOutlet weak var seekDeltaTextField: UITextField!
    @IBOutlet weak var seekDeltaTimeTextField: UITextField!
    
    @IBOutlet weak var ffEnabledLabel: UILabel!
    @IBOutlet weak var timeshiftEnabledLabel: UILabel!
    @IBOutlet weak var rwEnabledLabel: UILabel!
    
    @IBAction func fastForwardAction(_ sender: UIButton) {
        guard let text = seekDeltaTextField.text, let value = Int64(text) else { return }
        onSeeking(value)
    }
    
    @IBAction func rewindAction(_ sender: UIButton) {
        guard let text = seekDeltaTextField.text, let value = Int64(text) else { return }
        onSeeking(-value)
    }
    
    @IBAction func fastForwardTimeAction(_ sender: UIButton) {
        guard let text = seekDeltaTimeTextField.text, let value = Int64(text) else { return }
        onSeekingTime(value)
    }
    
    @IBAction func rewindTimeAction(_ sender: UIButton) {
        guard let text = seekDeltaTimeTextField.text, let value = Int64(text) else { return }
        onSeekingTime(-value)
    }
    
    @IBAction func reloadAction(_ sender: UIButton) {
        onReload()
    }
    
    @IBAction func startOverAction(_ sender: UIButton) {
        onStartOver()
    }
    
    @IBAction func ccAction(_ sender: UIButton) {
        onCC()
    }
    
    @IBAction func goLiveAction(_ sender: UIButton) {
        onGoLive()
    }
    
    var paused: Bool = false
    @IBOutlet weak var pausePlayButton: UIButton!
    @IBAction func pauseResumeAction(_ sender: UIButton) {
        let value = paused
        paused = !value
        pausePlayButton.setTitle(paused ? "PLAY" : "PAUSE", for: [])
        onPauseResumed(value)
    }
    
    var onSeekingTime: (Int64) -> Void = { _ in }
    var onSeeking: (Int64) -> Void = { _ in }
    var onTimeTick: () -> Void = { _ in }
    var onViewDidLoad: () -> Void = { _ in }
    var onPauseResumed: (Bool) -> Void = { _ in }
    var onReload: () -> Void = { _ in }
    var onGoLive: () -> Void = { _ in }
    var onStartOver: () -> Void = { _ in }
    var onCC: () -> Void = { }
    
    /// Queue where `timer` runs
    fileprivate let queue = DispatchQueue(label: "com.emp.refapp.testEnv.timestamp",
                                          qos: DispatchQoS.background,
                                          attributes: DispatchQueue.Attributes.concurrent)
    
    /// The oneShot timer used to trigger `ServerTime` refresh requests
    fileprivate var timer: DispatchSourceTimer?
    
    deinit {
        timer?.setEventHandler{}
        timer?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.scheduleRepeating(deadline: .now() + .seconds(1), interval: .seconds(1))
        timer?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.onTimeTick()
            }
        }
        timer?.resume()
        
        onViewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
