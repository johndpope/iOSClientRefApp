//
//  BannerPromotionLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-30.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class BannerPromotionLayout: CollectionViewLayout {
    override func contentHeight(width: CGFloat) -> CGFloat {
        return cellHeight(width: width)
    }
    
    override func thumbnailHeight(width: CGFloat) -> CGFloat {
        let aspect:CGFloat = 4 / 9
        return thumbnailWidth(width: width) * aspect
    }
    
    override func cellHeight(width: CGFloat) -> CGFloat {
        return thumbnailHeight(width: width)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes.filter{
            if let collectionView = collectionView {
                $0.frame.size.height = collectionView.frame.height
            }
            return rect.contains($0.frame) || rect.intersects($0.frame)
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
         print("BANNER targetContentOffset:",proposedContentOffset,super.targetContentOffset(forProposedContentOffset: proposedContentOffset))
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
    override func prepare() {
        guard let collectionView = collectionView else { return }
        attributes = (0..<collectionView.numberOfItems(inSection: 0)).flatMap{
            layoutAttributesForItem(at: IndexPath(item: $0, section: 0))
        }
    }
}
