//
//  AssetPreviewCell.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-05-31.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

protocol PreviewAssetCellConfig {
    func headerHeight(index: Int) -> CGFloat
    func rowHeight(index: Int) -> CGFloat
}

extension PreviewAssetCellConfig {
    func headerHeight(index: Int) -> CGFloat {
        return 40
    }
}

class AssetPreviewCell: UICollectionViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func reset() {
        titleLabel.isHidden = true
    }
    
    func thumbnail(title: String?) {
        titleLabel.isHidden = title == nil
        titleLabel.text = title
        thumbnailView.image = #imageLiteral(resourceName: "assetPlaceholder")
    }
}