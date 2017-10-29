//
//  HeroPromotionCell.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-22.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure

class HeroPromotionCell: UICollectionViewCell, EditorialCell {

    typealias ContentEditorial = HeroItemPromotionEditorial
    
    private var editorial: HeroItemPromotionEditorial? = nil
    var selectedAsset: (Asset) -> Void = { _ in }
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var editorialText: UILabel!
    @IBOutlet weak var heroBanner: UIImageView!
    
    weak var tapGestureRecognizer: UITapGestureRecognizer!
    func tapGestureAction(_ sender: UITapGestureRecognizer) {
        guard let asset = editorial?.data else { return }
        selectedAsset(asset)
    }
    
    func reset() {
        heroBanner.image = #imageLiteral(resourceName: "assetPlaceholder")
        editorial = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
        tapGestureRecognizer = gesture
        addGestureRecognizer(gesture)
    }

    func configure(with carousel: HeroPromotionEditorial?, for index: Int, size: CGSize) {
        guard let carousel = carousel else { return }
        reset()
        
        guard let editorial: HeroItemPromotionEditorial = carousel.editorial(for: index) else { return }
        self.editorial = editorial
        
        if carousel.usesItemSpecificEditorials {
            title.text = editorial.title?.uppercased()
            editorialText.text = editorial.text
        }
        
        
        // Promotional Art
        let cellSize = carousel.heroLayout.thumbnailSize(width: size.width)
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
