//
//  BasicPromotionCell.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure
import Kingfisher

class BasicPromotionCell: UICollectionViewCell, EditorialCell {

    typealias ContentEditorial = BasicPromotionEditorial
    
    private var editorial: BasicItemPromotionEditorial?
    var selectedAsset: (Asset) -> Void = { _ in }
    
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    func reset() {
        thumbnailView.image = #imageLiteral(resourceName: "assetPlaceholder")
        editorial = nil
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
        tapGestureRecognizer = gesture
        addGestureRecognizer(gesture)
    }

    
    weak var tapGestureRecognizer: UITapGestureRecognizer!
    func tapGestureAction(_ sender: UITapGestureRecognizer) {
        guard let asset = editorial?.data else { return }
        selectedAsset(asset)
    }
    
    func configure(with carousel: BasicPromotionEditorial?, for index: Int) {
        guard let carousel = carousel else { return }
        reset()
        
        guard let editorial: BasicItemPromotionEditorial = carousel.editorial(for: index) else { return }
        self.editorial = editorial
        
        if carousel.usesItemSpecificEditorials {
            title.text = editorial.title
        }
        
        
        // Promotional Art
        let cellSize = carousel.portraitLayout.thumbnailSize()
        if let url = editorial.imageUrl() {
            thumbnailView
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
