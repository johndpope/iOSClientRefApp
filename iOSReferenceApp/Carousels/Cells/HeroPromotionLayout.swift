//
//  HeroPromotionalLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-24.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class HeroPromotionLayout: CollectionViewLayout {
    var editorial: HeroPromotionEditorial!
    
    
    /// The full height of the content as bound by the underlying collectionView's width
    internal func contentHeight(width: CGFloat) -> CGFloat {
        let cell = cellHeight(width: width)
        
        // Total promotional height
        let editorialHeight = editorial.headerHeight ?? 0
        let footerHeight = editorial.footerHeight
        
        return cell + editorialHeight + footerHeight
    }
    
    //
    private func cellHeight(width: CGFloat) -> CGFloat {
        let thumbnail = thumbnailHeight(width: width)
        // Total cell height
        let itemEditorialHeight = editorial.cellEditorialHeight
        return thumbnail + itemEditorialHeight
    }
    
    internal func cellWidth(width: CGFloat) -> CGFloat {
        return width - 2 * editorial.sideInset
    }
    
    internal func thumbnailHeight(width: CGFloat) -> CGFloat {
        // Thumbnail view is 3:2 aspect of width
        let aspect:CGFloat = 2 / 3
        return thumbnailWidth(width: width) * aspect
    }
    
    internal func thumbnailWidth(width: CGFloat) -> CGFloat {
        return cellWidth(width: width)
    }
    
    internal func thumbnailSize(width: CGFloat) -> CGSize {
        return CGSize(width: thumbnailWidth(width: width),
                      height: thumbnailHeight(width: width))
    }
    
    // MARK: - Overrides
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return CGSize.zero }
        return CGSize(width: contentWidth, height: contentHeight(width: collectionView.bounds.width))
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        cache = []
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        // Thumbnail view is 3:2 aspect of width
        let aspect:CGFloat = 2 / 3
        let width = pageWidth
        let cellWidth = width - editorial.sideInset * 2
        let thumbnailSize = CGSize(width: cellWidth, height: cellWidth * aspect)
        let itemEditorialHeight = editorial.cellEditorialHeight
        let cellHeight = thumbnailSize.height + itemEditorialHeight
        
        let editorialHeight = (editorial.headerHeight ?? 0) + editorial.topInset
        if editorialHeight > 0 {
            carouselEditorialAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: 0))
            carouselEditorialAttribute!.frame = CGRect(x: 0, y: 0, width: width, height: editorialHeight)
            cache.append(carouselEditorialAttribute!)
        }
        
        
        let footerHeight = editorial.footerHeight
        carouselFooterAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: IndexPath(item: 0, section: 0))
        carouselFooterAttribute!.frame = CGRect(x: 0, y: cellHeight+editorialHeight, width: width, height: footerHeight)
        cache.append(carouselFooterAttribute!)
        
        var offset: CGFloat = editorial.sideInset
        let other:[UICollectionViewLayoutAttributes] = (0..<collectionView.numberOfItems(inSection: 0)).map {
            let indexPath = IndexPath(item: $0, section: 0)
            
            // Item
            let frame = CGRect(x: offset, y: editorialHeight, width: cellWidth, height: cellHeight)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            
            offset += cellWidth + editorial.sideInset/2
            
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
        return CGSize(width: bounds.width, height: contentHeight(width: bounds.width))
    }
}
