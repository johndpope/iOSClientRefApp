//
//  PortraitTrioPromotionLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-25.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class PortraitTrioPromotionLayout: CollectionViewLayout {
    var cellEditorialHeight: CGFloat = CarouselListViewModel.Shared().editorialHeight
    
    override func cellHeight(width: CGFloat) -> CGFloat {
        let thumbHeight = thumbnailHeight(width: width)
        // Total cell height
        return thumbHeight + cellEditorialHeight
    }
    
    
    override func thumbnailHeight(width: CGFloat) -> CGFloat {
        // TODO: Refactor out aspect ratio
        let aspect:CGFloat = 16 / 9
        return thumbnailWidth(width: width) * aspect
    }
    
    override func thumbnailWidth(width: CGFloat) -> CGFloat {
        let availableWidth = cellWidth(width: width) - 2 * configuration.contentSpacing
        return availableWidth / 3
    }
}

