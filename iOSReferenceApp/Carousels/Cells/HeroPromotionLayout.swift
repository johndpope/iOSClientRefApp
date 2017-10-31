//
//  HeroPromotionalLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-24.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class HeroPromotionLayout: CollectionViewLayout {
    var cellEditorialHeight: CGFloat = 43
    
    override func cellHeight(width: CGFloat) -> CGFloat {
        let thumbnail = thumbnailHeight(width: width)
        // Total cell height
        let itemEditorialHeight = cellEditorialHeight
        return thumbnail + itemEditorialHeight
    }
}

