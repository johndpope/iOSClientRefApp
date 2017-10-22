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
        return 28
    }
}

class AssetPreviewCell: UICollectionViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var boxView: UIView!
    
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
    
    func applyShadow(radius: CGFloat = 3, cornerRadius: CGFloat) {
        shadowView.isHidden = false
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.shadowRadius = radius
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: cornerRadius).cgPath
    }
    
    func applyBox(border: UIColor, background: UIColor, alpha: CGFloat) {
        boxView.layer.borderWidth = 1
        boxView.layer.borderColor = border.cgColor
        
        boxView.backgroundColor = background
        boxView.alpha = alpha
    }
}
