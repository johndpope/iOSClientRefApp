//
//  PortraitTrioPromotionLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-25.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class PortraitTrioPromotionLayout: CollectionViewLayout {
    var editorial: PortraitTrioPromotionEditorial!
    
    
    override func cellHeight(width: CGFloat) -> CGFloat {
        let thumbHeight = thumbnailHeight(width: width)
        // Total cell height
        let itemEditorialHeight = (editorial.cellEditorialHeight ?? 0)
        return thumbHeight + itemEditorialHeight
    }
    
    
    override func thumbnailHeight(width: CGFloat) -> CGFloat {
        // TODO: Refactor out aspect ratio
        let aspect:CGFloat = 16 / 9
        return thumbnailWidth(width: width) * aspect
    }
    
    override func thumbnailWidth(width: CGFloat) -> CGFloat {
        let availableWidth = cellWidth(width: width) - editorial.sideInset * 2
        return availableWidth / 3
    }
}

