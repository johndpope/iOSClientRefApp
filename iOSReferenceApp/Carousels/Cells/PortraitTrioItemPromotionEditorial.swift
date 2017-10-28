//
//  PortraitTrioItemPromotionEditorial.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

struct PortraitTrioItemPromotionEditorial: ContentEditorial {
    struct Data {
        let first: Asset
        let second: Asset?
        let third: Asset?
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
    
    func imageUrl(callback: (Data) -> Asset?) -> URL? {
        return callback(data)?
            .images(locale: "en")
            .prefere(orientation: .landscape)
            .validImageUrls()
            .first
    }
    
    func prefetchImageUrls() -> [URL] {
        return [data.first, data.second, data.third]
            .flatMap{ $0 }
            .flatMap{
                $0.images(locale: "en")
                    .prefere(orientation: .landscape)
                    .validImageUrls()
                    .first
        }
    }
}
