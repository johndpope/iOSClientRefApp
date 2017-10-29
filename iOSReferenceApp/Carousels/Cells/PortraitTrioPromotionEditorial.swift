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
import Kingfisher

class PortraitTrioPromotionEditorial {
    lazy var portraitLayout: PortraitTrioPromotionLayout = { [unowned self] in
        return PortraitTrioPromotionLayout(editorial: self)
        }()
    
    fileprivate var itemEditorials: [PortraitTrioItemPromotionEditorial] = []
    
    init() {
        portraitLayout.use(pagination: true)
    }
    
    // MARK: Editorial Layout
    let usesCarouselSpecificEditorial: Bool = false
    let usesItemSpecificEditorials: Bool = true
    
    // MARK: Header
    var headerHeight: CGFloat? { return nil }
    var title: String?  { return nil }
    var text: String?  { return nil }
    
    // MARK: Footer
    let footerHeight: CGFloat = 50
    
    // MARK: General Layout
    let cellEditorialHeight: CGFloat = 43
    let sideInset: CGFloat = 30
    let topInset: CGFloat = 10
    
    func append(content: [ContentEditorial]) {
        let filtered = content.flatMap{ $0 as? PortraitTrioItemPromotionEditorial }
        self.itemEditorials.append(contentsOf: filtered)
    }
}

extension PortraitTrioPromotionEditorial {
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

extension PortraitTrioPromotionEditorial: CarouselEditorial {
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

extension PortraitTrioPromotionEditorial: EmbeddedCarouselLayoutDelegate {
    func estimatedCellSize(for bounds: CGRect) -> CGSize {
        return portraitLayout.estimatedCellSize(for: bounds)
    }
}
