//
//  CarouselViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-22.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure
import Kingfisher

import UIKit

protocol CarouselLayoutDelegate: class {
    func carouselCellSize(for bounds: CGRect) -> CGSize
}



protocol CarouselViewModelType {
    associatedtype EditorialData
    associatedtype Content: CarouselItemViewModelType
    
    var editorial: EditorialData { get }
    var content: [Content] { get }
}


struct CarouselEditorialFakeData {
    let promotionalType: PromotionalType
    let editorialTitle: String?
    let editorialText: String?
    
    init(type: PromotionalType = .hero, title: String? = nil, text: String? = nil) {
        self.promotionalType = type
        self.editorialTitle = title
        self.editorialText = text
    }
    
    enum PromotionalType {
        case hero
//        case poster
    }
    
    var usesCarouselSpecificEditorial: Bool {
        switch promotionalType {
        case .hero: return false
//        case .poster: return true
        }
    }
    
    var usesItemSpecificEditorials: Bool {
        switch promotionalType {
        case .hero: return true
//        case .poster: return false
        }
    }
}


class CarouselViewModel<Editorial, ItemEditorial>: CarouselViewModelType {
    fileprivate(set) var editorial: Editorial
    var content: [CarouselItemViewModel<ItemEditorial>] = []
    let layout = HeroPromotionalLayout()
    
    init(carousel: Editorial, data: [(Asset, ItemEditorial)]) {
        self.editorial = carousel
        self.content = data.map{ CarouselItemViewModel(data: $0.0, editorial: $0.1) }
        
        layout.carouselSpecificEditorialHeight = 43
        layout.carouselFooterHeight = 60
        layout.itemSpecificEditorialHeight = 43
        layout.carouselContentInset = 30
    }
    
    // 1. Main Table View
    //      - CarouselListViewModel
    //      - CarouselList
    //          * One section per carousel
    //
    // 2. Row Collectionview
    //      - CarouselViewModel
    //      - CarouselItem (to be renamed) + AssetList
    //      - Editorial:
    //          * Promotional title (carousel name)
    //          * Promotional text
    //          * Promotional Type (Hero, New, Featured, etc)
    //
    // 3. Item in collectionView
    //      - CarouselAssetViewModel
    //      - Asset
    //      - Editorial:
    //          * Promotional title (asset name?)
    //          * Promotional text
}

extension CarouselViewModel where Editorial == CarouselEditorialFakeData {
    func contentInset(forCellWidth cellWidth: CGFloat) -> CGFloat {
        return 10
    }
    
    func cellSize(forCellWidth cellWidth: CGFloat) -> CGSize {
        let thumbSize = thumbnailSize(forCellWidth: cellWidth)
        return CGSize(width: thumbSize.width, height: thumbSize.height+43)
    }
    
    func thumbnailSize(forCellWidth cellWidth: CGFloat) -> CGSize {
        let size = cellWidth - 2 * contentInset(forCellWidth: cellWidth)
        switch editorial.promotionalType {
        case .hero:
            // 9:6 Aspect, Full Cell
            return CGSize(width: size, height: size / 9 * 6)
        }
    }
    
    func thumbnailCornerRadius(forCellWidth cellWidth: CGFloat) -> CGFloat {
        switch editorial.promotionalType {
        case .hero: return 10
        }
    }
    
    func thumbnailProcessor(forCellWidth cellWidth: CGFloat) -> ImageProcessor {
        let cellSize = thumbnailSize(forCellWidth: cellWidth)
        let resizeProcessor = CrispResizingImageProcessor(referenceSize: cellSize, mode: ContentMode.aspectFill)
        let croppingProcessor = CroppingImageProcessor(size: cellSize)
        let roundedRectProcessor = RoundCornerImageProcessor(cornerRadius: thumbnailCornerRadius(forCellWidth: cellWidth))
        return (resizeProcessor>>croppingProcessor)>>roundedRectProcessor
    }
    
    func thumbnailOptions(forCellWidth cellWidth: CGFloat) ->  KingfisherOptionsInfo {
        return [
            .backgroundDecode,
            .cacheMemoryOnly,
            .processor(thumbnailProcessor(forCellWidth: cellWidth))
        ]
    }
    
    var preferedImageOrientation: Exposure.Image.Orientation {
        switch editorial.promotionalType {
        case .hero: return .landscape
        }
    }
    
    func imageUrl(for index: Int) -> URL? {
        return content[index]
            .asset
            .images(locale: "en")
            .prefere(orientation: preferedImageOrientation)
            .validImageUrls()
            .first
    }
}
