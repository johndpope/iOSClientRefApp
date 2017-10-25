//
//  PortraitTrioPromotionLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-25.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class PortraitTrioPromotionLayout: CollectionViewLayout {
    /// Calculated
    internal func contentHeight(for width: CGFloat) -> CGFloat {
        let cell = cellHeight(for: width)
        
        // Total promotional heigght
        let editorialHeight = delegate.carouselSpecificEditorialHeight ?? 0
        let footerHeight = delegate.carouselFooterHeight
        
        return cell + editorialHeight + footerHeight
    }
    
    internal func cellHeight(for width: CGFloat) -> CGFloat {
        let thumbnail = thumbnailHeight(for: width)
        // Total cell height
        let itemEditorialHeight = (delegate.itemSpecificEditorialHeight ?? 0)
        return thumbnail + itemEditorialHeight
    }
    
    internal func cellWidth() -> CGFloat {
        return pageWidth - 2 * delegate.carouselContentSideInset
    }
    
    internal func thumbnailHeight(for width: CGFloat) -> CGFloat {
        // Thumbnail view is 3:2 aspect of width
        let aspect:CGFloat = 3 / 2
        let thumbWidth = thumbnailWidth(for: width)
        return thumbWidth * aspect
    }
    
    internal func thumbnailWidth(for width: CGFloat) -> CGFloat {
        let cellWidth = width - delegate.carouselContentSideInset * 2
        let availableWidth = cellWidth - delegate.carouselContentSideInset * 2
        return availableWidth / 3
    }
    
    internal func thumbnailSize(for width: CGFloat) -> CGSize {
        return CGSize(width: thumbnailWidth(for: width),
                      height: thumbnailHeight(for: width))
    }
    
    // MARK: - Overrides
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return CGSize.zero }
        return CGSize(width: contentWidth, height: contentHeight(for: collectionView.bounds.size.width))
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        cache = []
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        let editorialHeight = (delegate.carouselSpecificEditorialHeight ?? 0) + delegate.carouselContentTopInset
        if editorialHeight > 0 {
            carouselEditorialAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: 0))
            carouselEditorialAttribute!.frame = CGRect(x: 0, y: 0, width: pageWidth, height: editorialHeight)
            cache = [carouselEditorialAttribute!]
        }
        
        
        let cellsHeight = cellHeight(for: cellWidth())
        
        let footerHeight = delegate.carouselFooterHeight
        carouselFooterAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: IndexPath(item: 0, section: 0))
        carouselFooterAttribute!.frame = CGRect(x: 0, y: cellsHeight+editorialHeight, width: pageWidth, height: footerHeight)
        cache.append(carouselFooterAttribute!)
        
        var offset: CGFloat = delegate.carouselContentSideInset
        let other:[UICollectionViewLayoutAttributes] = (0..<collectionView.numberOfItems(inSection: 0)).map {
            let indexPath = IndexPath(item: $0, section: 0)
            
            // Item
            let frame = CGRect(x: offset, y: editorialHeight, width: cellWidth(), height: cellsHeight)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            
            offset += cellWidth() + delegate.carouselContentSideInset/2
            
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

extension PortraitTrioPromotionLayout: EmbeddedCarouselLayoutDelegate {
    func carouselCellSize(for bounds: CGRect) -> CGSize {
        return CGSize(width: bounds.size.width, height: contentHeight(for: bounds.size.width))
    }
}
