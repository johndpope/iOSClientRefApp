//
//  AssetViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-06-02.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class AssetViewModel: LocalizedAssetEntity {
    fileprivate(set) var asset: Asset
    
    typealias ExposureImage = Image
    
    init?(asset: Asset) {
        guard let type = asset.type else { return nil }
        self.asset = asset
        self.type = type
    }
    
    fileprivate(set) var type: Asset.AssetType
}

extension AssetViewModel: Hashable {
    var hashValue: Int {
        return asset.assetId.hashValue
    }
}

extension AssetViewModel: Equatable {
    public static func == (lhs: AssetViewModel, rhs: AssetViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension AssetViewModel {
    var publicationDate: String? {
        return asset.publications?.first?.publicationDate
    }
    
    var availableFromDate: String? {
        return asset.publications?.first?.fromDate
    }
    
    var availableToDate: String? {
        return asset.publications?.first?.toDate
    }
}
