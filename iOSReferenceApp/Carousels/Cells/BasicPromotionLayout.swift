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
    internal func contentHeight() -> CGFloat {
        let cell = cellHeight()
        
        // Total promotional heigght
        let editorialHeight = editorial.headerHeight ?? 0
        let footerHeight = editorial.footerHeight
        
        print(#function,cell + editorialHeight + footerHeight,cellHeight())
        
        print("thumbnailHeight",thumbnailHeight())
        print("thumbnailWidth",thumbnailWidth())
        
        return cell + editorialHeight + footerHeight
    }
    
    internal func cellHeight() -> CGFloat {
        let thumbHeight = thumbnailHeight()
        // Total cell height
        let itemEditorialHeight = (editorial.titleHeight ?? 0)
        return thumbHeight + itemEditorialHeight
    }
    
    internal func cellWidth() -> CGFloat {
        let itemsPerRow = CGFloat(editorial.itemsPerRow)
        return (pageWidth - 2 * editorial.sideInset - (itemsPerRow-1)*editorial.sideInset/2)/itemsPerRow
    }
    
    internal func thumbnailHeight() -> CGFloat {
        let aspectRatio = editorial.aspectRatio.height / editorial.aspectRatio.width
        return thumbnailWidth() * aspectRatio
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
        
        let editorialHeight = (editorial.headerHeight ?? 0) + editorial.topInset
        if editorialHeight > 0 {
            carouselEditorialAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: 0))
            carouselEditorialAttribute!.frame = CGRect(x: 0, y: 0, width: pageWidth, height: editorialHeight)
            cache.append(carouselEditorialAttribute!)
        }
        
        
        let footerHeight = editorial.footerHeight
        carouselFooterAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: IndexPath(item: 0, section: 0))
        carouselFooterAttribute!.frame = CGRect(x: 0, y: cellHeight()+editorialHeight, width: pageWidth, height: footerHeight)
        cache.append(carouselFooterAttribute!)
        
        var offset: CGFloat = editorial.sideInset
        let other:[UICollectionViewLayoutAttributes] = (0..<collectionView.numberOfItems(inSection: 0)).map {
            let indexPath = IndexPath(item: $0, section: 0)
            
            // Item
            let frame = CGRect(x: offset, y: editorialHeight, width: cellWidth(), height: cellHeight())
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            
            offset += cellWidth() + editorial.sideInset/2
            
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
        return CGSize(width: bounds.width, height: contentHeight())
    }
}
