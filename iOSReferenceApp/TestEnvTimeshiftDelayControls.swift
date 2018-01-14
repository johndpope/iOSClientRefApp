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
    
    @IBOutlet weak var wallclockTimeLabel: UILabel!
    @IBOutlet weak var playheadTimeLabel: UILabel!
    @IBOutlet weak var playheadPositionLabel: UILabel!
    
    @IBOutlet weak var timeshiftDelayTextField: UITextField!
    @IBOutlet weak var seekDeltaTextField: UITextField!
    
    @IBAction func timeshiftAction(_ sender: UIButton) {
        guard let text = timeshiftDelayTextField.text, let value = Int64(text) else { return }
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
    
    var onTimeshifting: (Int64) -> Void = { _ in }
    var onSeeking: (Int64) -> Void = { _ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
