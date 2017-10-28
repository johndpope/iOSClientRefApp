//
//  UICollectionViewLayoutPagination.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class UICollectionViewLayoutPagination {
    init(layout: UICollectionViewLayout) {
        self.layout = layout
    }
    
    // MARK: - Pagination
    unowned var layout: UICollectionViewLayout
    fileprivate var mostRecentOffset: CGPoint = CGPoint.zero
    func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if velocity.x == 0 {
            return mostRecentOffset
        }
        
        if let cv = layout.collectionView {
            
            let cvBounds = cv.bounds
            let halfWidth = cvBounds.size.width * 0.5;
            
            
            if let attributesForVisibleCells = layout.layoutAttributesForElements(in: cvBounds) {
                
                var candidateAttributes : UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells {
                    
                    // == Skip comparison with non-cell items (headers and footers) == //
                    if attributes.representedElementCategory != UICollectionElementCategory.cell {
                        continue
                    }
                    
                    if (attributes.center.x == 0) || (attributes.center.x > (cv.contentOffset.x + halfWidth) && velocity.x < 0) {
                        continue
                    }
                    candidateAttributes = attributes
                }
                
                // Beautification step , I don't know why it works!
                if(proposedContentOffset.x == -(cv.contentInset.left)) {
                    return proposedContentOffset
                }
                
                guard let _ = candidateAttributes else {
                    return mostRecentOffset
                }
                mostRecentOffset = CGPoint(x: floor(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
                return mostRecentOffset
                
            }
        }
        
        // fallback
        mostRecentOffset = layout.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        return mostRecentOffset
    }
}
