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
    @IBOutlet weak var epgTableView: UITableView!
    
    @IBOutlet weak var programIdLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var wallclockTimeLabel: UILabel!
    @IBOutlet weak var playheadTimeLabel: UILabel!
    @IBOutlet weak var playheadPositionLabel: UILabel!
    
    @IBOutlet weak var timeshiftDelayTextField: UITextField!
    
    var viewModel: ChannelViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension TestEnvTimeshiftDelay: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.epgAvailable ? viewModel.content.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "epgCell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard viewModel.epgAvailable else {
            cell.textLabel?.text = "EPG unavailable"
            return
        }
        
        let cellViewModel = viewModel.content[indexPath.row]
        
    }
}

extension TestEnvTimeshiftDelay: UITableViewDelegate {
    
}
