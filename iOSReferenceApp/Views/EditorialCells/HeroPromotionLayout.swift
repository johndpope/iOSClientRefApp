//
//  HeroPromotionalLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-24.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

protocol CarouselLayoutDelegate {
    var carouselSpecificEditorialHeight: CGFloat? { get }
    var carouselFooterHeight: CGFloat { get }
    var carouselContentSideInset: CGFloat { get }
    var carouselContentTopInset: CGFloat { get }
    var itemSpecificEditorialHeight: CGFloat? { get }
}

class UICollectionViewLayoutPagination {
    init(layout: UICollectionViewLayout) {
        self.layout = layout
    }
    
    // MARK: - Pagination
    unowned var layout: UICollectionViewLayout
    fileprivate var mostRecentOffset: CGPoint = CGPoint.zero
    func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if velocity.x == 0 {
            return mostRecentOffset
        }
        
        if let cv = layout.collectionView {
            
            let cvBounds = cv.bounds
            let halfWidth = cvBounds.size.width * 0.5;
            
            
            if let attributesForVisibleCells = layout.layoutAttributesForElements(in: cvBounds) {
                
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
        mostRecentOffset = layout.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        return mostRecentOffset
    }
}

class CollectionViewLayout: UICollectionViewLayout {
    // MARK: - Configuration
    var delegate: CarouselLayoutDelegate!
    
    /// Quick access of the underlying collectionView page width
    var pageWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.bounds.size.width
    }
    
    // MARK: - Pagination
    func use(pagination value: Bool) {
        pagination = (value ? UICollectionViewLayoutPagination(layout: self) : nil)
    }
    fileprivate var pagination: UICollectionViewLayoutPagination?
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if let pagination = pagination {
            return pagination.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity:velocity)
        }
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }
    
    
    // Private storage of header + footer
    internal var carouselEditorialAttribute: UICollectionViewLayoutAttributes?
    internal var carouselFooterAttribute: UICollectionViewLayoutAttributes?
    
    /// Cache for layout attribs
    internal var cache: [UICollectionViewLayoutAttributes] = []
    
    /// Incremented as cells are added
    internal var contentWidth: CGFloat = 0
    
    // MARK: - Overrides
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionElementKindSectionHeader {
            return carouselEditorialAttribute
        }
        
        if elementKind == UICollectionElementKindSectionHeader {
            return carouselFooterAttribute
        }
        
        return nil
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let stickyHeader = carouselEditorialAttribute, let collectionView = collectionView {
            let contentOffset = collectionView.contentOffset
            let oldFrame = stickyHeader.frame
            stickyHeader.frame = CGRect(x: contentOffset.x, y: oldFrame.minY, width: oldFrame.width, height: oldFrame.height)
        }
        
        if let stickyFooter = carouselFooterAttribute, let collectionView = collectionView {
            let contentOffset = collectionView.contentOffset
            let oldFrame = stickyFooter.frame
            stickyFooter.frame = CGRect(x: contentOffset.x, y: oldFrame.minY, width: oldFrame.width, height: oldFrame.height)
        }
        
        return cache.filter{ $0.frame.intersects(rect) }
    }
}

class HeroPromotionLayout: CollectionViewLayout {
    // MARK: - Internal
    
    /// The full height of the content as bound by the underlying collectionView's width
    internal func contentHeight() -> CGFloat {
        let cell = cellHeight()
        
        // Total promotional heigght
        let editorialHeight = delegate.carouselSpecificEditorialHeight ?? 0
        let footerHeight = delegate.carouselFooterHeight
        
        return cell + editorialHeight + footerHeight
    }
    
    //
    private func cellHeight() -> CGFloat {
        let thumbnail = thumbnailHeight()
        // Total cell height
        let itemEditorialHeight = (delegate.itemSpecificEditorialHeight ?? 0)
        return thumbnail + itemEditorialHeight
    }
    
    internal func cellWidth() -> CGFloat {
        return pageWidth - 2 * delegate.carouselContentSideInset
    }
    
    internal func thumbnailHeight() -> CGFloat {
        // Thumbnail view is 3:2 aspect of width
        let aspect:CGFloat = 2 / 3
        return thumbnailWidth() * aspect
    }
    
    internal func thumbnailWidth() -> CGFloat {
        return cellWidth()
    }
    
    internal func thumbnailSize() -> CGSize {
        return CGSize(width: thumbnailWidth(),
                      height: thumbnailHeight())
    }
    
    // MARK: - Overrides
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight())
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        cache = []
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        // Thumbnail view is 3:2 aspect of width
        let aspect:CGFloat = 2 / 3
        let width = pageWidth
        let cellWidth = width - delegate.carouselContentSideInset * 2
        let thumbnailSize = CGSize(width: cellWidth, height: cellWidth * aspect)
        let itemEditorialHeight = (delegate.itemSpecificEditorialHeight ?? 0)
        let cellHeight = thumbnailSize.height + itemEditorialHeight
        
        let editorialHeight = (delegate.carouselSpecificEditorialHeight ?? 0) + delegate.carouselContentTopInset
        if editorialHeight > 0 {
            carouselEditorialAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: 0))
            carouselEditorialAttribute!.frame = CGRect(x: 0, y: 0, width: width, height: editorialHeight)
            cache = [carouselEditorialAttribute!]
        }
        
        
        let footerHeight = delegate.carouselFooterHeight
        carouselFooterAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: IndexPath(item: 0, section: 0))
        carouselFooterAttribute!.frame = CGRect(x: 0, y: cellHeight+editorialHeight, width: width, height: footerHeight)
        cache.append(carouselFooterAttribute!)
        
        var offset: CGFloat = delegate.carouselContentSideInset
        let other:[UICollectionViewLayoutAttributes] = (0..<collectionView.numberOfItems(inSection: 0)).map {
            let indexPath = IndexPath(item: $0, section: 0)
            
            // Item
            let frame = CGRect(x: offset, y: editorialHeight, width: cellWidth, height: cellHeight)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            
            offset += cellWidth + delegate.carouselContentSideInset/2
            
            // Update total offset
            contentWidth = max(contentWidth, frame.maxX)
            
            
            return attributes
        }
        
        cache.append(contentsOf: other)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}

extension HeroPromotionLayout: EmbeddedCarouselLayoutDelegate {
    func estimatedCellSize(for bounds: CGRect) -> CGSize {
        return CGSize(width: bounds.width, height: contentHeight())
    }
}
