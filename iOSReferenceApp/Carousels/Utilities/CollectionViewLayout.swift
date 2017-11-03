//
//  CollectionViewLayout.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class CollectionViewLayout: UICollectionViewLayout {
    
    // MARK: - Pagination
    func use(pagination value: Bool) {
        pagination = (value ? UICollectionViewLayoutPagination(layout: self) : nil)
    }
    
    fileprivate var pagination: UICollectionViewLayoutPagination?
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if let pagination = pagination {
            return pagination.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity:velocity)
        }
        print("targetContentOffset:velocity",proposedContentOffset,super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity))
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }
    
    // MARK: - Configuration
    internal struct Configuration {
        let edgeInsets: UIEdgeInsets
        
        let headerHeight: CGFloat?
        let footerHeight: CGFloat
        
        let contentSpacing: CGFloat
        
        init(edgeInsets: UIEdgeInsets = CarouselListViewModel.Shared().edgeInsets,
             headerHeight: CGFloat? = nil,
             footerHeight: CGFloat = CarouselListViewModel.Shared().footerHeight,
             contentSpacing: CGFloat = CarouselListViewModel.Shared().contentSpacing) {
            self.edgeInsets = edgeInsets
            self.headerHeight = headerHeight
            self.footerHeight = footerHeight
            self.contentSpacing = contentSpacing
        }
    }
    internal var configuration: Configuration = Configuration()
    
    // MARK: - Content
    
    /// The full height of the content as bound by the underlying collectionView's width
    internal func contentHeight(width: CGFloat) -> CGFloat {
        let cell = cellHeight(width: width)
        
        // Total promotional height
        let editorialHeight = configuration.headerHeight ?? 0
        let footerHeight = configuration.footerHeight
        
        return cell + editorialHeight + footerHeight
    }
    
    //
    internal func cellHeight(width: CGFloat) -> CGFloat {
        return 0
    }
    
    internal func cellWidth(width: CGFloat) -> CGFloat {
        return width - (configuration.edgeInsets.left + configuration.edgeInsets.right)
    }
    
    internal func thumbnailHeight(width: CGFloat) -> CGFloat {
        // TODO: Refactor out aspect ratio
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
    
    internal func contentWidth(at index: Int) -> CGFloat {
        return contentOffset(at: index+1)
    }
    
    internal func contentOffset(at index: Int) -> CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return configuration.edgeInsets.left + CGFloat(index) * (cellWidth(width: collectionView.bounds.width) + configuration.contentSpacing)
    }
    
    // MARK: - Overrides
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return CGSize.zero }
        return CGSize(width: contentWidth(at: collectionView.numberOfItems(inSection: 0)),
                      height: contentHeight(width: collectionView.bounds.width))
    }
    
    var attributes: [UICollectionViewLayoutAttributes] = []
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        attributes = (0..<collectionView.numberOfItems(inSection: 0)).flatMap{ layoutAttributesForItem(at: IndexPath(item: $0, section: 0)) }
        if let header = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: 0)) {
            attributes.append(header)
        }
        if let footer = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter, at: IndexPath(item: 0, section: 0)) {
            attributes.append(footer)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else { return nil }
        let editorialHeight = (configuration.headerHeight ?? 0) + configuration.edgeInsets.top
        let height = cellHeight(width: collectionView.bounds.width)
        let width = cellWidth(width: collectionView.bounds.width)
        
        let offset = contentOffset(at: indexPath.item)
        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attribute.frame = CGRect(x: offset, y: editorialHeight, width: width, height: height)
        return attribute
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else { return nil }
        let width = cellWidth(width: collectionView.bounds.width)
        if let headerHeight = configuration.headerHeight, elementKind == UICollectionElementKindSectionHeader {
            let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: indexPath)
            attribute.frame = CGRect(x: 0, y: 0, width: width, height: headerHeight)
            attribute.zIndex = -1
            return attribute
        }
        
        let height = cellHeight(width: collectionView.bounds.width)
        let headerHeight = configuration.headerHeight ?? 0
        if elementKind == UICollectionElementKindSectionFooter {
            let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: indexPath)
            attribute.frame = CGRect(x: 0, y: height+headerHeight, width: width, height: configuration.footerHeight)
            attribute.zIndex = -1
            return attribute
        }
        return nil
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes.filter {
            if $0.representedElementKind == UICollectionElementKindSectionHeader || $0.representedElementKind == UICollectionElementKindSectionFooter {
                if let collectionView = collectionView {
                    let oldFrame = $0.frame
                    $0.frame = CGRect(x: collectionView.contentOffset.x, y: oldFrame.minY, width: oldFrame.width, height: oldFrame.height)
                }
            }
            return rect.contains($0.frame) || rect.intersects($0.frame)
        }
    }
}

extension CollectionViewLayout: EmbeddedCarouselLayoutDelegate {
    func estimatedCellSize(for bounds: CGRect) -> CGSize {
        // TODO: Incorrect?
        return CGSize(width: bounds.width, height: contentHeight(width: bounds.width))
    }
}
