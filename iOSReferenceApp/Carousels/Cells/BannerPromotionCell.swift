//
//  BannerPromotionCell.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-30.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure
import Kingfisher

class BannerPromotionCell: UICollectionViewCell, EditorialCell {
    
    typealias ContentEditorial = BannerPromotionEditorial
    
    private var editorial: BannerItemPromotionEditorial?
    var selectedAsset: (Asset) -> Void = { _ in }

    @IBOutlet weak var banner: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
        tapGestureRecognizer = gesture
        addGestureRecognizer(gesture)
    }
    
    weak var tapGestureRecognizer: UITapGestureRecognizer!
    func tapGestureAction(_ sender: UITapGestureRecognizer) {
        guard let asset = editorial?.data else { return }
        selectedAsset(asset)
    }
    
    func reset() {
        banner.image = #imageLiteral(resourceName: "assetPlaceholder")
        title.text = nil
        descriptionLabel.text = nil
        descriptionLabel.isHidden = true
    }
    
    
    func configure(with carousel: BannerPromotionEditorial?, for index: Int, size: CGSize) {
        guard let carousel = carousel else { return }
        reset()
        
        
    }
}
