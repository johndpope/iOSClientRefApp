//
//  PortraitPromotionEditorial.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import CoreGraphics
import Kingfisher
import Exposure

class BasicPromotionEditorial {
    let basicLayout: BasicPromotionLayout
    
    fileprivate(set) var itemEditorials: [BasicItemPromotionEditorial] = []
    
    init(title: String, aspectRatio: AspectRatio = AspectRatio()) {
        basicLayout = BasicPromotionLayout()
        basicLayout.configuration = CollectionViewLayout.Configuration(headerHeight: CarouselListViewModel.Shared().slimEditorialHeight)
        basicLayout.aspectRatio = aspectRatio.height / aspectRatio.width
        headerViewModel = CarouselHeaderViewModel(title: title, text: nil, sideInset: basicLayout.configuration.edgeInsets.left)
        
    }
    
    struct AspectRatio {
        let width: CGFloat
        let height: CGFloat
        
        init(width: CGFloat = 3, height: CGFloat = 2) {
            self.width = width
            self.height = height
        }
    }
    
    let headerViewModel: CarouselHeaderViewModel?
    
    func append(content: [ContentEditorial]) {
        let filtered = content.flatMap{ $0 as? BasicItemPromotionEditorial }
        itemEditorials.append(contentsOf: filtered)
    }
}

extension BasicPromotionEditorial {
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
        if basicLayout.aspectRatio > 0 {
            return .landscape
        }
        else if basicLayout.aspectRatio < 0 {
            return .portrait
        }
        return .square
    }
}

extension BasicPromotionEditorial: CarouselEditorial {
    var content: [ContentEditorial] {
        return itemEditorials
    }
    
    var layout: CollectionViewLayout {
        return basicLayout
    }
    
    func editorial<T>(for index: Int) -> T? where T : ContentEditorial {
        return content[index] as? T
    }
    
    var count: Int {
        return content.count
    }
}

extension BasicPromotionEditorial: EmbeddedCarouselLayoutDelegate {
    func estimatedCellSize(for bounds: CGRect) -> CGSize {
        return basicLayout.estimatedCellSize(for: bounds)
    }
}
