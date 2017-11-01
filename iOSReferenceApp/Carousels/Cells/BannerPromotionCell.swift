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
        banner.image = #imageLiteral(resourceName: "assetPlaceholder-9-4")
        title.text = nil
        descriptionLabel.text = nil
        descriptionLabel.isHidden = true
    }
    
    
    func configure(with carousel: BannerPromotionEditorial?, for index: Int, size: CGSize) {
        guard let carousel = carousel else { return }
        reset()
        
        guard let editorial: BannerItemPromotionEditorial = carousel.editorial(for: index) else { return }
        self.editorial = editorial
        
        
        title.text = editorial.title
        descriptionLabel.text = editorial.text
        
        // Promotional Art
        let cellSize = carousel.bannerLayout.thumbnailSize(width: size.width)
        if let url = editorial.imageUrl() {
            banner
                .kf
                .setImage(with: url,
                          placeholder: #imageLiteral(resourceName: "assetPlaceholder-9-4"),
                          options: carousel.thumbnailOptions(for: cellSize)) { (image, error, cache, url) in
                            if let error = error {
                                print("Kingfisher: ",error)
                            }
            }
        }
    }
}
