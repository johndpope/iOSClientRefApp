//
//  TestEnvTimeshiftDelayControls.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2018-01-14.
//  Copyright © 2018 emp. All rights reserved.
//

import UIKit

class TestEnvTimeshiftDelayControls: UITableViewController {
    var onViewDidLoad: () -> Void = { _ in }
    
    @IBOutlet weak var programIdLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var seekableStartLabel: UILabel!
    @IBOutlet weak var seekableEndLabel: UILabel!
    @IBOutlet weak var bufferedStartLabel: UILabel!
    @IBOutlet weak var bufferedEndLabel: UILabel!
    
    
    @IBOutlet weak var wallclockTimeLabel: UILabel!
    @IBOutlet weak var playheadTimeLabel: UILabel!
    @IBOutlet weak var playheadPositionLabel: UILabel!
    
    @IBOutlet weak var timeshiftDelayTextField: UITextField!
    @IBOutlet weak var seekDeltaTextField: UITextField!
    
    @IBAction func timeshiftAction(_ sender: UIButton) {
        guard let text = timeshiftDelayTextField.text, let value = Int64(text) else {
            onTimeshifting(nil)
            return
        }
        onTimeshifting(value)
    }
    
    @IBAction func fastForwardAction(_ sender: UIButton) {
        guard let text = seekDeltaTextField.text, let value = Int64(text) else { return }
        onSeeking(value)
    }
    
    @IBAction func rewindAction(_ sender: UIButton) {
        guard let text = seekDeltaTextField.text, let value = Int64(text) else { return }
        onSeeking(-value)
    }
    
    var onTimeshifting: (Int64?) -> Void = { _ in }
    var onSeeking: (Int64) -> Void = { _ in }
    var onTimeTick: () -> Void = { _ in }
    
    
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
