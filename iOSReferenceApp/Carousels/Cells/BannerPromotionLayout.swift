//
//  BannerPromotionLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-30.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class BannerPromotionLayout: CollectionViewLayout {
    var editorial: BannerPromotionEditorial!
    
    override func contentHeight(width: CGFloat) -> CGFloat {
        return cellHeight(width: width)
    }
    
    override func thumbnailHeight(width: CGFloat) -> CGFloat {
        // Thumbnail view is 9:2 aspect of width
        let aspect:CGFloat = 2 / 9
        return thumbnailWidth(width: width) * aspect
    }
    
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        attributes = (0..<collectionView.numberOfItems(inSection: 0)).flatMap{ layoutAttributesForItem(at: IndexPath(item: $0, section: 0)) }
    }
}
