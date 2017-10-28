//
//  MainMenuContentCell.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-27.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class MainMenuContentCell: UITableViewCell {

    @IBOutlet weak var activeIndicator: UIView!
    @IBOutlet weak var contentTitle: UILabel!
    
    private var viewModel: MainMenuContentViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(viewModel: MainMenuContentViewModel) {
        self.viewModel = viewModel
        contentTitle.text = viewModel.title
        activeIndicator.isHidden = !viewModel.isActive
        
        contentTitle.textColor = viewModel.textColor
    }
}
