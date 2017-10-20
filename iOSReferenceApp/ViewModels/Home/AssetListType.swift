//
//  AssetListType.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-15.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

protocol AssetListType {
    var content: [AssetViewModel] { get }
    
    
    var preferredCellSize: CGSize { get }
    var preferredThumbnailSize: CGSize { get }
    func preferredCellSize(forWidth width: CGFloat) -> CGSize
    func preferredThumbnailSize(forWidth width: CGFloat) -> CGSize
    var thumbnailCornerRadius: CGFloat { get }
    
    func fetchMetadata(batch: Int, callback: @escaping (Int, ExposureError?) -> Void)
    
    func imageUrl(for indexPath: IndexPath) -> URL?
    
    func anyTitle() -> String?
}

extension AssetListType {
    var thumbnailCornerRadius: CGFloat {
        return 6
    }
    
    var preferredCellSize: CGSize {
        return CGSize(width: 108, height: 186)
    }
    
    var preferredThumbnailSize: CGSize {
        return CGSize(width: 96, height: 150)
    }
    
    var previewCellPadding: CGFloat {
        return 0
    }
}

extension AssetListType {
    func fetchMetadata(batch: Int, callback: @escaping (Int, ExposureError?) -> Void) {
        callback(-1, nil)
    }
    
    func imageUrl(for indexPath: IndexPath) -> URL? {
        return content[indexPath.row]
            .images(locale: "en")
            .prefere(orientation: .portrait)
            .validImageUrls()
            .first
    }
}
