//
//  BannerPromotionLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-30.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class BannerPromotionLayout: CollectionViewLayout {
    var editorial: BannerPromotionEditorial!
    
    internal func contentHeight(width: CGFloat) -> CGFloat {
        return cellHeight(width: width)
    }
    
    private func cellHeight(width: CGFloat) -> CGFloat {
        return thumbnailHeight(width: width)
    }
    
    internal func cellWidth(width: CGFloat) -> CGFloat {
        return width
    }
    
    internal func thumbnailHeight(width: CGFloat) -> CGFloat {
        // Thumbnail view is 9:2 aspect of width
        let aspect:CGFloat = 2 / 9
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
//    override var collectionViewContentSize: CGSize {
//        guard let collectionView = collectionView else { return CGSize.zero }
//        return CGSize(width: contentWidth, height: contentHeight(width: collectionView.bounds.width))
//    }
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        cache = []
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        cache = (0..<collectionView.numberOfItems(inSection: 0)).flatMap{
            let attribute = layoutAttributesForItem(at: IndexPath(item: $0, section: 0))
            if let frame = attribute?.frame {
                // TODO: Remove reference to contentWidth
                contentWidth = max(contentWidth, frame.maxX)
            }
            return attribute
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { return rect.contains($0.frame) || rect.intersects($0.frame) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else {
            return nil
        }
        
        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        let cellSize = CGSize(width: cellWidth(width: collectionView.bounds.width),
                              height: cellHeight(width: collectionView.bounds.width))
        
        let offset = CGFloat(indexPath.item) * cellSize.width
        
        attribute.frame = CGRect(x: offset, y: 0, width: cellSize.width, height: cellSize.height)
        
        return attribute
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return CGSize.zero
        }
        
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let lastItem = numberOfItems - 1
        
        guard let lastCell = layoutAttributesForItem(at: IndexPath(item: lastItem, section: 0)) else {
            return CGSize.zero
        }
        
        return CGSize(width: lastCell.frame.maxX, height: collectionView.frame.height)
    }
}

extension BannerPromotionLayout: EmbeddedCarouselLayoutDelegate {
    func estimatedCellSize(for bounds: CGRect) -> CGSize {
        return CGSize(width: bounds.width, height: contentHeight(width: bounds.width))
    }
}
