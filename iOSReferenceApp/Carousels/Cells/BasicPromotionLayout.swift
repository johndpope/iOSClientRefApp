//
//  PortraitPromotionLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class BasicPromotionLayout: CollectionViewLayout {
    var editorial: BasicPromotionEditorial!
    
    /// The full height of the content as bound by the underlying collectionView's width
    internal func contentHeight(width: CGFloat) -> CGFloat {
        let cell = cellHeight(width: width)
        
        // Total promotional heigght
        let editorialHeight = editorial.headerHeight ?? 0
        let footerHeight = editorial.footerHeight
        
        return cell + editorialHeight + footerHeight
    }
    
    internal func cellHeight(width: CGFloat) -> CGFloat {
        let thumbHeight = thumbnailHeight(width: width)
        // Total cell height
        let itemEditorialHeight = (editorial.titleHeight ?? 0)
        return thumbHeight + itemEditorialHeight
    }
    
    internal func cellWidth(width: CGFloat) -> CGFloat {
        let itemsPerRow = CGFloat(editorial.itemsPerRow)
        return (width - 2 * editorial.sideInset - (itemsPerRow-1)*editorial.sideInset/2)/itemsPerRow
    }
    
    internal func thumbnailHeight(width: CGFloat) -> CGFloat {
        let aspectRatio = editorial.aspectRatio.height / editorial.aspectRatio.width
        return thumbnailWidth(width: width) * aspectRatio
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
        let width = collectionView.bounds.width
        cache = []
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        let editorialHeight = (editorial.headerHeight ?? 0) + editorial.topInset
        if editorialHeight > 0 {
            carouselEditorialAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: 0))
            carouselEditorialAttribute!.frame = CGRect(x: 0, y: 0, width: pageWidth, height: editorialHeight)
            cache.append(carouselEditorialAttribute!)
        }
        
        
        let footerHeight = editorial.footerHeight
        carouselFooterAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: IndexPath(item: 0, section: 0))
        carouselFooterAttribute!.frame = CGRect(x: 0, y: cellHeight(width: width)+editorialHeight, width: pageWidth, height: footerHeight)
        cache.append(carouselFooterAttribute!)
        
        var offset: CGFloat = editorial.sideInset
        let other:[UICollectionViewLayoutAttributes] = (0..<collectionView.numberOfItems(inSection: 0)).map {
            let indexPath = IndexPath(item: $0, section: 0)
            
            // Item
            let frame = CGRect(x: offset, y: editorialHeight, width: cellWidth(width: width), height: cellHeight(width: width))
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            
            offset += cellWidth(width: width) + editorial.sideInset/2
            
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

extension BasicPromotionLayout: EmbeddedCarouselLayoutDelegate {
    func estimatedCellSize(for bounds: CGRect) -> CGSize {
        return CGSize(width: bounds.width, height: contentHeight(width: bounds.width))
    }
}
