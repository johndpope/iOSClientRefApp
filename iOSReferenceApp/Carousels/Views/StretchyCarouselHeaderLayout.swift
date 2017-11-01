//
//  StretchyCarouselHeaderLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-30.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

protocol StretchyCarouselHeaderLayoutDelegate: class {
    var usesStretchyHeader: Bool { get }
    var startingStretchyHeaderHeight: CGFloat { get }
    func cellSize(for indexPath: IndexPath) -> CGSize
    var edgeInsets: UIEdgeInsets { get }
    var itemSpacing: CGFloat { get }
}


let StretchyCollectionHeaderKind = "StretchyCollectionHeaderKind"

class StretchyCarouselHeaderLayout: UICollectionViewLayout {
    var delegate: StretchyCarouselHeaderLayoutDelegate!
    
    var attributes: [UICollectionViewLayoutAttributes] = []
    
    override func prepare() {
        super.prepare()

        // Can't do much without a collectionView.
        guard let collectionView = collectionView else {
            return
        }
        
        attributes = (0..<collectionView.numberOfItems(inSection: 0)).flatMap{
            layoutAttributesForItem(at: IndexPath(item: $0, section: 0))
        }

        if delegate.usesStretchyHeader {
            if let headerAttribute = layoutAttributesForSupplementaryView(ofKind: StretchyCollectionHeaderKind, at: IndexPath(item: 0, section: 0)) {
                attributes.append(headerAttribute)
            }
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let visibleAttributes = attributes.filter { return rect.contains($0.frame) || rect.intersects($0.frame) }
        
        // Check for our Stretchy Header
        // We want to find a collectionHeader and stretch it while scrolling.
        // But first lets make sure we've scrolled far enough.
        let offset = collectionView?.contentOffset ?? CGPoint.zero
        let minY = -delegate.edgeInsets.top
        if offset.y < minY {
            let extraOffset = fabs(offset.y - minY)

            // Find our collectionHeader and stretch it while scrolling.
            let stretchyHeader = visibleAttributes.filter {
                return $0.representedElementKind == StretchyCollectionHeaderKind
                }.first

            if let collectionHeader = stretchyHeader {
                let headerSize = collectionHeader.frame.size
                collectionHeader.frame.size.height = max(minY, headerSize.height + extraOffset)
                collectionHeader.frame.origin.y = collectionHeader.frame.origin.y - extraOffset
            }
        }
        return visibleAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)

        var yOffset = delegate.startingStretchyHeaderHeight + delegate.edgeInsets.top

        if indexPath.item > 0 {
            let previous = (0..<indexPath.item).reduce(0) {  $0 + delegate.cellSize(for: IndexPath(item: $1, section: 0)).height }
            yOffset += previous
        }

        let cellSize = delegate.cellSize(for: indexPath)

        attribute.frame = CGRect(x: delegate.edgeInsets.left, y: yOffset, width: cellSize.width, height: cellSize.height)

        return attribute
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard delegate.usesStretchyHeader else { return nil }
        guard let collectionView = collectionView else { return nil }
        
        let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: StretchyCollectionHeaderKind, with: indexPath)
        
        attribute.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: delegate.startingStretchyHeaderHeight)
        return attribute
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return CGSize.zero
        }

        let lastItem = collectionView.numberOfItems(inSection: 0) - 1

        guard let lastCell = layoutAttributesForItem(at: IndexPath(item: lastItem, section: 0)) else {
            return CGSize.zero
        }

        return CGSize(width: collectionView.frame.width, height: lastCell.frame.maxY + delegate.edgeInsets.bottom)
    }
}
