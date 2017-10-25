//
//  PortraitTrioPromotionEditorial.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-25.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import CoreGraphics
import Exposure

class PortraitTrioPromotionEditorial {
    
    fileprivate(set) var portraitLayout = PortraitTrioPromotionLayout()
    var content: [PortraitTrioItemPromotionEditorial] = []
    
    init() {
        portraitLayout.delegate = self
        portraitLayout.use(pagination: true)
    }
    
    // MARK: Editorial Layout
    let usesCarouselSpecificEditorial: Bool = false
    let usesItemSpecificEditorials: Bool = true
    
    // Carousel Editorial
    let title: String? = nil
    let text: String? = nil
    
    // MARK: Header & Footer
    let editorialHeight: CGFloat? = nil
    let footerHeight: CGFloat = 60
    let itemEditorialHeight: CGFloat? = 43
    
    // MARK: General Layout
    let contentSideInset: CGFloat = 30
    let contentTopInset: CGFloat = 10
    
    func append(content: [ContentEditorial]) {
        let filtered = content.flatMap{ $0 as? PortraitTrioItemPromotionEditorial }
        self.content.append(contentsOf: filtered)
    }
}


extension PortraitTrioPromotionEditorial: CarouselEditorial {
    var layout: CollectionViewLayout {
        return portraitLayout
    }
    
    func editorial<T>(for index: Int) -> T? where T : ContentEditorial {
        return content[index] as? T
    }
    
    var count: Int {
        return content.count
    }
    
    func imageUrls(for index: Int) -> [URL] {
        return []
    }
    
}

extension PortraitTrioPromotionEditorial: CarouselLayoutDelegate {
    var carouselSpecificEditorialHeight: CGFloat? {
        return editorialHeight
    }
    
    var carouselFooterHeight: CGFloat {
        return footerHeight
    }
    
    var carouselContentSideInset: CGFloat {
        return contentSideInset
    }
    
    var carouselContentTopInset: CGFloat {
        return contentTopInset
    }
    
    var itemSpecificEditorialHeight: CGFloat? {
        return itemEditorialHeight
    }
}

extension PortraitTrioPromotionEditorial: EmbeddedCarouselLayoutDelegate {
    func carouselCellSize(for bounds: CGRect) -> CGSize {
        return portraitLayout.carouselCellSize(for: bounds)
    }
}

struct PortraitTrioItemPromotionEditorial {
    struct Data {
        let first: Asset
        let second: Asset
        let third: Asset
    }
    
    init(title: String? = nil, text: String? = nil, data: Data) {
        self.title = title
        self.text = text
        self.data = data
    }
    
    // Carousel Editorial
    let title: String?
    let text: String?
    
    let data: Data
}
