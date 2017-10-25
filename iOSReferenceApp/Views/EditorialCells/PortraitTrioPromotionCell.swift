//
//  PortraitTrioPromotionCell.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-24.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure
import Kingfisher

class PortraitTrioPromotionCell: UICollectionViewCell, EditorialCell {
    
    typealias ContentEditorial = PortraitTrioPromotionEditorial

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var text: UILabel!
    
    @IBOutlet weak var first: UIImageView!
    @IBOutlet weak var second: UIImageView!
    @IBOutlet weak var third: UIImageView!
    
    func reset() {
        first.image = nil
        second.image = nil
        third.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with carousel: PortraitTrioPromotionEditorial?, for index: Int) {
        guard let carousel = carousel else { return }
        reset()
        
        guard let editorial: PortraitTrioItemPromotionEditorial = carousel.editorial(for: index) else { return }
        
        if carousel.usesItemSpecificEditorials {
            title.text = editorial.title?.uppercased()
            text.text = editorial.text
        }
        
        
        // Promotional Art
        let cellSize = carousel.portraitLayout.thumbnailSize(for: carousel.portraitLayout.cellWidth())
        let imageOptions = carousel.thumbnailOptions(for: cellSize)
        
        load(imageView: first, options: imageOptions, editorial: editorial) { $0.first }
        load(imageView: second, options: imageOptions, editorial: editorial) { $0.second }
        load(imageView: third, options: imageOptions, editorial: editorial) { $0.third }
    }
    
    private func load(imageView: UIImageView, options: KingfisherOptionsInfo, editorial: PortraitTrioItemPromotionEditorial, asset: (PortraitTrioItemPromotionEditorial.Data) -> Asset?) {
        if let url = editorial.imageUrl(callback: asset) {
            imageView
                .kf
                .setImage(with: url,
                          placeholder: #imageLiteral(resourceName: "assetPlaceholder"),
                          options: options) { (image, error, cache, url) in
                            if let error = error {
                                print("Kingfisher: ",error)
                            }
            }
        }
    }
}
