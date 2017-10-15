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
    //    associatedtype AssetType
    
    var content: [AssetViewModel] { get }
    
    
    var preferredCellSize: CGSize { get }
    var preferredThumbnailSize: CGSize { get }
    func preferredCellSize(forWidth width: CGFloat) -> CGSize
    func preferredThumbnailSize(forWidth width: CGFloat) -> CGSize
    
    func fetchMetadata(batch: Int, callback: @escaping (Int, ExposureError?) -> Void)
    
    func imageUrl(for indexPath: IndexPath) -> URL?
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
