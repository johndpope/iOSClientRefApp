//
//  MainMenuPushNavigationCell.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-27.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class MainMenuPushNavigationCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    private var viewModel: MainMenuPushNavigationViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func bind(viewModel: MainMenuPushNavigationViewModel) {
        self.viewModel = viewModel
        
        title.text = viewModel.title
        title.textColor = viewModel.textColor
        
        icon.image = viewModel.image
    }
    
}
