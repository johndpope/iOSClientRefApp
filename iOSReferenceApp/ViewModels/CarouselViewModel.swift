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

protocol EmbeddedCarouselLayoutDelegate: class {
    func estimatedCellSize(for bounds: CGRect) -> CGSize
}

protocol EditorialCell {
    associatedtype Editorial
    func configure(with editorial: Editorial?, for index: Int)
}

protocol CarouselEditorial: EmbeddedCarouselLayoutDelegate {
    var layout: CollectionViewLayout { get }
    func editorial<T: ContentEditorial>(for index: Int) -> T?
    var content: [ContentEditorial] { get }
    func append(content: [ContentEditorial])
    
    var count: Int { get }
    
    // MARK: Editorial Layout
    var usesCarouselSpecificEditorial: Bool { get }
    var usesItemSpecificEditorials: Bool { get }
    
    // Carousel Editorial
    var title: String? { get }
    var text: String? { get }
    
    // MARK: Header & Footer
    var editorialHeight: CGFloat? { get }
    var footerHeight: CGFloat { get }
    var itemEditorialHeight: CGFloat? { get }
    
    // MARK: General Layout
    var contentSideInset: CGFloat { get }
    var contentTopInset: CGFloat { get }
}

protocol ContentEditorial {
    func prefetchImageUrls() -> [URL]
}

// Cell
//
// CellViewModel
// Editorial
// Data (asset(s))
//
// ViewModel
// CarouselEditorial
// Layout

class CarouselViewModel {
    fileprivate(set) var editorial: CarouselEditorial
    
    init(editorial: CarouselEditorial) {
        self.editorial = editorial
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
