//
//  AssetViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-06-02.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class AssetViewModel: LocalizedEntity {
    fileprivate(set) var asset: Asset
    
    typealias ExposureImage = Image
    
    init?(asset: Asset) {
        guard let type = asset.type else { return nil }
        self.asset = asset
        self.type = type
    }
    
    fileprivate(set) var type: Asset.AssetType
}

extension AssetViewModel {
    var locales: [String] {
        return asset.localized?.flatMap{ $0.locale } ?? []
    }
    
    func localizedData(locale: String) -> LocalizedData? {
        return asset.localized?.filter{ $0.locale == locale }.first
    }
    
    func localizations() -> [LocalizedData] {
        return asset.localized ?? []
    }
    
    func anyTitle(locale: String) -> String {
        if let title = title(locale: locale) { return title }
        else if let originalTitle = asset.originalTitle { return originalTitle }
        else if let assetId = asset.assetId { return assetId }
        return "NO TITIE"
    }
    
    func anyDescription(locale: String) -> String {
        if let description = localizedData(locale: locale)?.allDescriptions().last {
            return description
        }
        return localizations().flatMap{ $0.allDescriptions() }.last ?? ""
    }
}

extension AssetViewModel: Hashable {
    var hashValue: Int {
        return asset.assetId?.hashValue ?? -1
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
