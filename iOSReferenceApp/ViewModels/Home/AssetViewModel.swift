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



protocol LocalizedEntity {
    var locales: [String] { get }
    func localizedData(locale: String) -> LocalizedData?
    func localizations() -> [LocalizedData]
    func anyTitle(locale: String) -> String
}

extension LocalizedEntity {
    func title(locale: String) -> String? {
        if let result = localizedData(locale: locale)?.title {
            return result
        }
        return localizations().flatMap{ $0.title }.first
    }
    
    func tinyDescription(locale: String) -> String? {
        return localizedData(locale: locale)?.tinyDescription
    }
    
    func shortDescription(locale: String) -> String? {
        return localizedData(locale: locale)?.shortDescription
    }
    
    func description(locale: String) -> String? {
        return localizedData(locale: locale)?.description
    }
    
    func longDescription(locale: String) -> String? {
        return localizedData(locale: locale)?.longDescription
    }
    
    
    func images(locale: String) -> [Image] {
        return localizedData(locale: locale)?.images ?? []
    }
    
    func descriptions(locale: String) -> [String] {
        let data = localizedData(locale: locale)
        return [data?.tinyDescription,
                data?.shortDescription,
                data?.description,
                data?.longDescription]
            .flatMap{ $0 }
    }
    
    func shortestDescription(locale: String) -> String? {
        return descriptions(locale: locale).first
    }
    
    func longestDescription(locale: String) -> String? {
        return descriptions(locale: locale).last
    }
    
    func validImageUrls(locale: String) -> [URL] {
        return images(locale: locale)
            .flatMap{ $0.url }
            .filter{ $0.hasPrefix("http") }
            .flatMap{ URL(string: $0) }
    }
}
