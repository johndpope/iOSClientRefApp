//
//  HeroPromotionCell.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-22.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class HeroPromotionCell: UICollectionViewCell, EditorialCell {

    typealias ContentEditorial = HeroItemPromotionEditorial
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var editorialText: UILabel!
    @IBOutlet weak var heroBanner: UIImageView!
    
    func reset() {
        heroBanner.image = #imageLiteral(resourceName: "assetPlaceholder")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with carousel: HeroPromotionEditorial?, for index: Int) {
        guard let carousel = carousel else { return }
        reset()
        
        guard let editorial: HeroItemPromotionEditorial = carousel.editorial(for: index) else { return }
        
        if carousel.usesItemSpecificEditorials {
            title.text = editorial.title?.uppercased()
            editorialText.text = editorial.text
        }
        
        
        // Promotional Art
        let cellSize = carousel.heroLayout.thumbnailSize()
        if let url = editorial.imageUrl() {
            heroBanner
                .kf
                .setImage(with: url,
                          placeholder: #imageLiteral(resourceName: "assetPlaceholder"),
                          options: carousel.thumbnailOptions(for: cellSize)) { (image, error, cache, url) in
                            if let error = error {
                                print("Kingfisher: ",error)
                            }
            }
        }
    }
}
