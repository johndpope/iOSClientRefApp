//
//  MainMenuStaticDataCell.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-27.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class MainMenuStaticDataCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    private var viewModel: MainMenuStaticDataViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(viewModel: MainMenuStaticDataViewModel) {
        self.viewModel = viewModel
        
        title.text = viewModel.text
        title.textColor = viewModel.textColor
    }
}
