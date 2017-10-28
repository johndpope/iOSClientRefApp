//
//  HeroPromotionEditorial.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-24.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import CoreGraphics
import Exposure
import Kingfisher

class HeroPromotionEditorial {
    fileprivate(set) var heroLayout = HeroPromotionLayout()
    fileprivate var itemEditorials: [HeroItemPromotionEditorial] = []
    
    init() {
        heroLayout.delegate = self
        heroLayout.use(pagination: true)
    }
    
    // MARK: Editorial Layout
    let usesCarouselSpecificEditorial: Bool = false
    let usesItemSpecificEditorials: Bool = true
    
    // Carousel Editorial
    let title: String? = nil
    let text: String? = nil
    
    // MARK: Header & Footer
    let editorialHeight: CGFloat? = nil
    let footerHeight: CGFloat = 50
    let itemEditorialHeight: CGFloat? = 43
    
    // MARK: General Layout
    let contentSideInset: CGFloat = 30
    let contentTopInset: CGFloat = 10
    
    
    func append(content: [ContentEditorial]) {
        let filtered = content.flatMap{ $0 as? HeroItemPromotionEditorial }
        itemEditorials.append(contentsOf: filtered)
    }
}

extension HeroPromotionEditorial {
    func thumbnailOptions(for size: CGSize) ->  KingfisherOptionsInfo {
        return [
            .backgroundDecode,
            .cacheMemoryOnly,
            .processor(thumbnailProcessor(for: size))
        ]
    }
    
    fileprivate func thumbnailCornerRadius(forCellWidth cellWidth: CGFloat) -> CGFloat {
        return 10
    }
    
    fileprivate func thumbnailProcessor(for size: CGSize) -> ImageProcessor {
        let resizeProcessor = CrispResizingImageProcessor(referenceSize: size, mode: ContentMode.aspectFill)
        let croppingProcessor = CroppingImageProcessor(size: size)
        let roundedRectProcessor = RoundCornerImageProcessor(cornerRadius: thumbnailCornerRadius(forCellWidth: size.width))
        return (resizeProcessor>>croppingProcessor)>>roundedRectProcessor
    }
    
    fileprivate var preferedImageOrientation: Exposure.Image.Orientation {
        return .landscape
    }
}

extension HeroPromotionEditorial: CarouselEditorial {
    var content: [ContentEditorial] {
        return itemEditorials
    }
    
    var layout: CollectionViewLayout {
        return heroLayout
    }
    
    func editorial<T>(for index: Int) -> T? where T : ContentEditorial {
        return content[index] as? T
    }
    
    var count: Int {
        return content.count
    }
}

extension HeroPromotionEditorial: CarouselLayoutDelegate {
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

extension HeroPromotionEditorial: EmbeddedCarouselLayoutDelegate {
    func estimatedCellSize(for bounds: CGRect) -> CGSize {
        return heroLayout.estimatedCellSize(for: bounds)
    }
}

struct HeroItemPromotionEditorial: ContentEditorial {
    init(title: String? = nil, text: String? = nil, data: Asset) {
        self.title = title
        self.text = text
        self.data = data
    }
    
    let data: Asset
    
    // Carousel Editorial
    let title: String?
    let text: String?
    
    func imageUrl() -> URL? {
        return data
            .images(locale: "en")
            .prefere(orientation: .landscape)
            .validImageUrls()
            .first
    }
}

extension HeroItemPromotionEditorial {
    func prefetchImageUrls() -> [URL] {
        let url = imageUrl()
        return url != nil ? [url!] : []
    }
}
