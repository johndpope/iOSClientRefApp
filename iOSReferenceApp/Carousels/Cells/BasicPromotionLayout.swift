//
//  PortraitPromotionLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class BasicPromotionLayout: CollectionViewLayout {
    var editorial: BasicPromotionEditorial!
    
    override func cellHeight(width: CGFloat) -> CGFloat {
        let thumbHeight = thumbnailHeight(width: width)
        // Total cell height
        let itemEditorialHeight = (editorial.titleHeight ?? 0)
        return thumbHeight + itemEditorialHeight
    }
    
    override func cellWidth(width: CGFloat) -> CGFloat {
        let itemsPerRow = CGFloat(editorial.itemsPerRow)
        return (width - 2 * editorial.sideInset - (itemsPerRow-1)*editorial.sideInset/2)/itemsPerRow
    }
    
    override func thumbnailHeight(width: CGFloat) -> CGFloat {
        // TODO: Refactor out aspect ratio
        let aspectRatio = editorial.aspectRatio.height / editorial.aspectRatio.width
        return thumbnailWidth(width: width) * aspectRatio
    }
}
