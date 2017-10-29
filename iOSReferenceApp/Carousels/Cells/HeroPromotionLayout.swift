//
//  HeroPromotionalLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-24.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class HeroPromotionLayout: CollectionViewLayout {
    unowned let editorial: HeroPromotionEditorial
    
    init(editorial: HeroPromotionEditorial) {
        self.editorial = editorial
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The full height of the content as bound by the underlying collectionView's width
    internal func contentHeight() -> CGFloat {
        let cell = cellHeight()
        
        // Total promotional height
        let editorialHeight = editorial.headerHeight ?? 0
        let footerHeight = editorial.footerHeight
        
        return cell + editorialHeight + footerHeight
    }
    
    //
    private func cellHeight() -> CGFloat {
        let thumbnail = thumbnailHeight()
        // Total cell height
        let itemEditorialHeight = editorial.cellEditorialHeight
        return thumbnail + itemEditorialHeight
    }
    
    internal func cellWidth() -> CGFloat {
        return pageWidth - 2 * editorial.sideInset
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
        let cellWidth = width - editorial.sideInset * 2
        let thumbnailSize = CGSize(width: cellWidth, height: cellWidth * aspect)
        let itemEditorialHeight = editorial.cellEditorialHeight
        let cellHeight = thumbnailSize.height + itemEditorialHeight
        
        let editorialHeight = (editorial.headerHeight ?? 0) + editorial.topInset
        if editorialHeight > 0 {
            carouselEditorialAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: 0))
            carouselEditorialAttribute!.frame = CGRect(x: 0, y: 0, width: width, height: editorialHeight)
            cache = [carouselEditorialAttribute!]
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
        return CGSize(width: bounds.width, height: contentHeight())
    }
}
