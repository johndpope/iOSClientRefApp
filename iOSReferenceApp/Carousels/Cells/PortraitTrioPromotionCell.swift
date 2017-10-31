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
    
    private var editorial: PortraitTrioItemPromotionEditorial?
    var selectedAsset: (Asset) -> Void = { _ in }

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var text: UILabel!
    
    @IBOutlet weak var first: UIImageView!
    @IBOutlet weak var second: UIImageView!
    @IBOutlet weak var third: UIImageView!
    
    weak var tapGestureRecognizer: UITapGestureRecognizer!
    func tapGestureAction(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: sender.view)
        if first.frame.contains(touchLocation) {
            guard let asset = editorial?.data.first else { return }
            selectedAsset(asset)
        }
        else if second.frame.contains(touchLocation) {
            guard let asset = editorial?.data.second else { return }
            selectedAsset(asset)
        }
        else if third.frame.contains(touchLocation) {
            guard let asset = editorial?.data.third else { return }
            selectedAsset(asset)
        }
    }
    
    func reset() {
        first.image = #imageLiteral(resourceName: "assetPlaceholder")
        second.image = #imageLiteral(resourceName: "assetPlaceholder")
        third.image = #imageLiteral(resourceName: "assetPlaceholder")
        editorial = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
        tapGestureRecognizer = gesture
        addGestureRecognizer(gesture)
    }
    
    func configure(with carousel: PortraitTrioPromotionEditorial?, for index: Int, size: CGSize) {
        guard let carousel = carousel else { return }
        reset()
        
        guard let editorial: PortraitTrioItemPromotionEditorial = carousel.editorial(for: index) else { return }
        self.editorial = editorial
        
        title.text = editorial.title.uppercased()
        text.text = editorial.text
        
        
        // Promotional Art
        let cellSize = carousel.portraitLayout.thumbnailSize(width: size.width)
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
        else {
            imageView.image = #imageLiteral(resourceName: "assetPlaceholder")
        }
    }
}
