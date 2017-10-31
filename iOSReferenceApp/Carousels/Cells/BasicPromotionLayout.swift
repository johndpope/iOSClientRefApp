//
//  PortraitPromotionLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class BasicPromotionLayout: CollectionViewLayout {
    var titleHeight: CGFloat = 28
    var itemsPerRow: Int = 2
    var aspectRatio: CGFloat = 3 / 2
    
    override func cellHeight(width: CGFloat) -> CGFloat {
        let thumbHeight = thumbnailHeight(width: width)
        // Total cell height
        return thumbHeight + titleHeight
    }
    
    override func cellWidth(width: CGFloat) -> CGFloat {
        let items = CGFloat(itemsPerRow)
        return (width - (configuration.edgeInsets.left + configuration.edgeInsets.right + (items-1)*configuration.contentSpacing))/items
    }
    
    override func thumbnailHeight(width: CGFloat) -> CGFloat {
        // TODO: Refactor out aspect ratio
//        let aspectRatio = editorial.aspectRatio.height / editorial.aspectRatio.width
        return thumbnailWidth(width: width) * aspectRatio
    }
}
