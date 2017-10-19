//
//  OfflineListCell.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-19.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class OfflineListCell: UITableViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    
    fileprivate var viewModel: OfflineListCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(viewModel: OfflineListCellViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        sizeLabel.text = viewModel.downloadSize
        expirationLabel.text = viewModel.expiration
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        
    }
    
    @IBAction func showDetailsAction(_ sender: UIButton) {
        
    }
}
