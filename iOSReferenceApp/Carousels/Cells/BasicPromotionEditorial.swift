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
    let portraitLayout = BasicPromotionLayout()
    
    
    fileprivate(set) var itemEditorials: [BasicItemPromotionEditorial] = []
    
    init(title: String, aspectRatio: AspectRatio = AspectRatio()) {
        self.title = title
        self.aspectRatio = aspectRatio
        portraitLayout.editorial = self
    }
    
    struct AspectRatio {
        let width: CGFloat
        let height: CGFloat
        
        init(width: CGFloat = 3, height: CGFloat = 2) {
            self.width = width
            self.height = height
        }
    }
    
    // MARK: Editorial Layout
    let usesCarouselSpecificEditorial: Bool = true
    let usesItemSpecificEditorials: Bool = true
    
    // Carousel Editorial
    let title: String?
    var text: String? { return nil }
    
    // MARK: Header & Footer
    let headerHeight: CGFloat? = 43
    let footerHeight: CGFloat = 50
    
    // MARK: Cell
    let titleHeight: CGFloat? = 28
    let itemsPerRow: Int = 2
    let aspectRatio: AspectRatio
    
    // MARK: General Layout
    let sideInset: CGFloat = 30
    let topInset: CGFloat = 10
    
    
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
        if aspectRatio.width > aspectRatio.height {
            return .landscape
        }
        else if aspectRatio.width < aspectRatio.height {
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
        return portraitLayout
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
        return portraitLayout.estimatedCellSize(for: bounds)
    }
}
