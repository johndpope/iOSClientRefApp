//
//  TestEnvTimeshiftDelay.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2018-01-11.
//  Copyright © 2018 emp. All rights reserved.
//

import UIKit

class TestEnvTimeshiftDelay: UIViewController {

    @IBOutlet weak var playerView: UIView!
    
    @IBOutlet weak var programIdLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var wallclockTimeLabel: UILabel!
    @IBOutlet weak var playheadTimeLabel: UILabel!
    @IBOutlet weak var playheadPositionLabel: UILabel!
    
    @IBOutlet weak var timeshiftDelayTextField: UITextField!
    @IBOutlet weak var seekDeltaTextField: UITextField!
    
    var viewModel: ChannelViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func timeshiftAction(_ sender: UIButton) {
        
    }
    
    @IBAction func seekDeltaAction(_ sender: UIButton) {
        
    }
}

extension TestEnvTimeshiftDelay: UITableViewDelegate {
    
}
