//
//  PortraitItemPromotionEditorial.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

struct PortraitItemPromotionEditorial: ContentEditorial {
    let data: Asset
    
    init(data: Asset, title: String? = nil) {
        self.data = data
        self.title = title
    }
    
    // Carousel Editorial
    let title: String?
    
    
    func imageUrl() -> URL? {
        return data
            .images(locale: "en")
            .prefere(orientation: .landscape)
            .validImageUrls()
            .first
    }
}

extension PortraitItemPromotionEditorial {
    func prefetchImageUrls() -> [URL] {
        let url = imageUrl()
        return url != nil ? [url!] : []
    }
}

