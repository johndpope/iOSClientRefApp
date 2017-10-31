//
//  BannerPromotionEditorial.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-30.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure
import Kingfisher

class BannerPromotionEditorial {
    let bannerLayout: BannerPromotionLayout
    
    fileprivate var itemEditorials: [BannerItemPromotionEditorial] = []
    
    init() {
        bannerLayout = BannerPromotionLayout()
        bannerLayout.configuration = CollectionViewLayout.Configuration(edgeInsets: UIEdgeInsets.zero, headerHeight: nil, footerHeight: 0, contentSpacing: 0)
    }
}

extension BannerPromotionEditorial: CarouselEditorial {
    func append(content: [ContentEditorial]) {
        let filtered = content.flatMap{ $0 as? BannerItemPromotionEditorial }
        itemEditorials.append(contentsOf: filtered)
    }
    
    var headerViewModel: CarouselHeaderViewModel? { return nil }
    
    func estimatedCellSize(for bounds: CGRect) -> CGSize {
        return bannerLayout.estimatedCellSize(for: bounds)
    }
    
    var content: [ContentEditorial] {
        return itemEditorials
    }
    
    var layout: CollectionViewLayout {
        return bannerLayout
    }
    
    func editorial<T>(for index: Int) -> T? where T : ContentEditorial {
        return content[index] as? T
    }
    
    var count: Int {
        return content.count
    }
}

extension BannerPromotionEditorial {
    func thumbnailOptions(for size: CGSize) ->  KingfisherOptionsInfo {
        return [
            .backgroundDecode,
            .cacheMemoryOnly,
            .processor(thumbnailProcessor(for: size))
        ]
    }
    
    fileprivate func thumbnailProcessor(for size: CGSize) -> ImageProcessor {
        let resizeProcessor = CrispResizingImageProcessor(referenceSize: size, mode: ContentMode.aspectFill)
        let croppingProcessor = CroppingImageProcessor(size: size)
        return resizeProcessor>>croppingProcessor
    }
    
    fileprivate var preferedImageOrientation: Exposure.Image.Orientation {
        return .landscape
    }
}

class BannerItemPromotionEditorial {
    init(data: Asset, title: String, text: String) {
        self.title = title
        self.text = text
        self.data = data
    }
    
    let data: Asset
    
    // Carousel Editorial
    let title: String
    let text: String
    
    func imageUrl() -> URL? {
        return data
            .images(locale: "en")
            .prefere(orientation: .landscape)
            .validImageUrls()
            .first
    }
}

extension BannerItemPromotionEditorial: ContentEditorial {
    func prefetchImageUrls() -> [URL] {
        let url = imageUrl()
        return url != nil ? [url!] : []
    }
}
