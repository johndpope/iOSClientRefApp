//
//  CollectionViewLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

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
