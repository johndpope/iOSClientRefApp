//
//  HeroPromotionalLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-24.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

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
