//
//  BannerPromotionEditorial.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-30.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class BannerPromotionEditorial {
    let bannerLayout = BannerPromotionLayout()
    
    fileprivate var itemEditorials: [BannerItemPromotionEditorial] = []
    
    
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
