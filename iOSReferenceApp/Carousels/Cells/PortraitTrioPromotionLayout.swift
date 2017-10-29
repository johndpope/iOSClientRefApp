//
//  PortraitTrioPromotionLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-25.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class PortraitTrioPromotionLayout: CollectionViewLayout {
    var editorial: PortraitTrioPromotionEditorial!
    
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
        let itemEditorialHeight = (editorial.cellEditorialHeight ?? 0)
        return thumbHeight + itemEditorialHeight
    }
    
    internal func cellWidth(width: CGFloat) -> CGFloat {
        return width - 2 * editorial.sideInset
    }
    
    internal func thumbnailHeight(width: CGFloat) -> CGFloat {
        let aspect:CGFloat = 16 / 9
        return thumbnailWidth(width: width) * aspect
    }
    
    internal func thumbnailWidth(width: CGFloat) -> CGFloat {
        let availableWidth = cellWidth(width: width) - editorial.sideInset * 2
        return availableWidth / 3
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
        
        
        let cellsHeight = cellHeight(width: width)
        
        let footerHeight = editorial.footerHeight
        carouselFooterAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: IndexPath(item: 0, section: 0))
        carouselFooterAttribute!.frame = CGRect(x: 0, y: cellsHeight+editorialHeight, width: pageWidth, height: footerHeight)
        cache.append(carouselFooterAttribute!)
        
        var offset: CGFloat = editorial.sideInset
        let other:[UICollectionViewLayoutAttributes] = (0..<collectionView.numberOfItems(inSection: 0)).map {
            let indexPath = IndexPath(item: $0, section: 0)
            
            // Item
            let frame = CGRect(x: offset, y: editorialHeight, width: cellWidth(width: width), height: cellsHeight)
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

extension PortraitTrioPromotionLayout: EmbeddedCarouselLayoutDelegate {
    func estimatedCellSize(for bounds: CGRect) -> CGSize {
        return CGSize(width: bounds.width, height: contentHeight(width: bounds.width))
    }
}
