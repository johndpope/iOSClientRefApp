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

protocol HeroPromotionalLayoutDelegate: class {
    func carouselSpecificEditorialHeight() -> CGFloat?
    func itemSpecificEditorialHeight() -> CGFloat?
    
    func pageWidth() -> CGFloat
}
class HeroPromotionalLayout: UICollectionViewLayout {
    weak var delegate: HeroPromotionalLayoutDelegate!
    
    fileprivate var cache: [UICollectionViewLayoutAttributes] = []
    
    fileprivate var edgeInset: CGFloat = 30
    
    /// Incremented as cells are added
    fileprivate var contentWidth: CGFloat = 0
    
    /// Calculated by asking delegate
    fileprivate var contentHeight: CGFloat = 0
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    
    var mostRecentOffset: CGPoint = CGPoint.zero
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if velocity.x == 0 {
            return mostRecentOffset
        }
        
        if let cv = self.collectionView {
            
            let cvBounds = cv.bounds
            let halfWidth = cvBounds.size.width * 0.5;
            
            
            if let attributesForVisibleCells = self.layoutAttributesForElements(in: cvBounds) {
                
                var candidateAttributes : UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells {
                    
                    // == Skip comparison with non-cell items (headers and footers) == //
                    if attributes.representedElementCategory != UICollectionElementCategory.cell {
                        continue
                    }
                    
                    if (attributes.center.x == 0) || (attributes.center.x > (cv.contentOffset.x + halfWidth) && velocity.x < 0) {
                        continue
                    }
                    candidateAttributes = attributes
                }
                
                // Beautification step , I don't know why it works!
                if(proposedContentOffset.x == -(cv.contentInset.left)) {
                    return proposedContentOffset
                }
                
                guard let _ = candidateAttributes else {
                    return mostRecentOffset
                }
                mostRecentOffset = CGPoint(x: floor(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
                return mostRecentOffset
                
            }
        }
        
        // fallback
        mostRecentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        return mostRecentOffset
    }
    
    var carouselEditorialAttribute: UICollectionViewLayoutAttributes?
    /// Note: As prepare() is called whenever the collection view's layout is invalidated, there are many situations in a typical implementation where you might need to recalculate attributes here. For example, the bounds of the UICollectionView might change - such as when the orientation changes - or items may be added or removed from the collection. These cases are out of scope for this tutorial, but it's important to be aware of them in a non-trivial implementation.
    override func prepare() {
        guard let collectionView = collectionView else { return }
        cache = []
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        // Thumbnail view is 3:2 aspect of width
        let aspect:CGFloat = 2 / 3
        let width = delegate.pageWidth()
        let cellWidth = width - edgeInset * 2
        let thumbnailSize = CGSize(width: cellWidth, height: cellWidth * aspect)
        let itemEditorialHeight = (delegate.itemSpecificEditorialHeight() ?? 0)
        let cellHeight = thumbnailSize.height + itemEditorialHeight
        
        let editorialHeight = delegate.carouselSpecificEditorialHeight() ?? 0
        if editorialHeight > 0 {
            carouselEditorialAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: 0))
            carouselEditorialAttribute!.frame = CGRect(x: 0, y: 0, width: width, height: editorialHeight)
            cache = [carouselEditorialAttribute!]
        }
        // Content height is Thumbnail + Item Editorial + Carousel Editorial
        contentHeight = cellHeight + editorialHeight
        
        
        
        
        var offset: CGFloat = edgeInset
        let other:[UICollectionViewLayoutAttributes] = (0..<collectionView.numberOfItems(inSection: 0)).map {
            let indexPath = IndexPath(item: $0, section: 0)
            
            // Item
            let frame = CGRect(x: offset, y: editorialHeight, width: cellWidth, height: cellHeight)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            
            offset += cellWidth + edgeInset/2
            
            // Update total offset
            contentWidth = max(contentWidth, frame.maxX)
            
            
            return attributes
        }
        cache.append(contentsOf: other)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
//    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        if elementKind == UICollectionElementKindSectionHeader {
//            guard let collectionView = collectionView else {
//                return nil
//            }
//
//            guard let editorialHeight = delegate.carouselSpecificEditorialHeight() else { return nil }
//
//            let pageWidth = delegate.pageWidth()
//            let contentOffset = collectionView.contentOffset
//            carouselEditorialAttribute?.frame = CGRect(x: contentOffset.x, y: 0, width: pageWidth, height: editorialHeight)
//            return carouselEditorialAttribute
//        }
//        return nil
//    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let stickyHeader = carouselEditorialAttribute, let collectionView = collectionView {
            let contentOffset = collectionView.contentOffset
            let oldFrame = stickyHeader.frame
            stickyHeader.frame = CGRect(x: contentOffset.x, y: 0, width: oldFrame.width, height: oldFrame.height)
        }
        
        return cache.filter{ $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
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
    
    init(carousel: Editorial, data: [(Asset, ItemEditorial)]) {
        self.editorial = carousel
        self.content = data.map{ CarouselItemViewModel(data: $0.0, editorial: $0.1) }
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
