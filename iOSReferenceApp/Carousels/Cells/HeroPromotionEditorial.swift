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
    let heroLayout:HeroPromotionLayout
    
    fileprivate var itemEditorials: [HeroItemPromotionEditorial] = []
    
    init() {
        heroLayout = HeroPromotionLayout()
    }
    
    var headerViewModel: CarouselHeaderViewModel? { return nil }
    
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
    
    
    fileprivate func thumbnailProcessor(for size: CGSize) -> ImageProcessor {
        let resizeProcessor = CrispResizingImageProcessor(referenceSize: size, mode: ContentMode.aspectFill)
        let croppingProcessor = CroppingImageProcessor(size: size)
        guard let roundedCorners = CarouselListViewModel.Shared().thumbnailRoundness else {
            return resizeProcessor>>croppingProcessor
        }
        let roundedRectProcessor = RoundCornerImageProcessor(cornerRadius: roundedCorners)
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

extension HeroPromotionEditorial: EmbeddedCarouselLayoutDelegate {
    func estimatedCellSize(for bounds: CGRect) -> CGSize {
        return heroLayout.estimatedCellSize(for: bounds)
    }
}
