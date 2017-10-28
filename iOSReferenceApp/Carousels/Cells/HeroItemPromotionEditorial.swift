//
//  HeroItemPromotionEditorial.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

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
