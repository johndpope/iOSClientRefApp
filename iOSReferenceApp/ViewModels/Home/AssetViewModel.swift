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



protocol LocalizedEntity {
    var locales: [String] { get }
    func localizedData(locale: String) -> LocalizedData?
    func localizations() -> [LocalizedData]
    func anyTitle(locale: String) -> String
    func anyDescription(locale: String) -> String
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
        if let result = localizedData(locale: locale)?.images {
            return result
        }
        return localizations().flatMap{ $0.images ?? [] }
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
}

extension LocalizedData {
    func allDescriptions() -> [String] {
        return [tinyDescription,
                shortDescription,
                description,
                longDescription]
            .flatMap{ $0 }
    }
}

extension Sequence where Self.Iterator.Element == Image {
    func validImageUrls() -> [URL] {
        return self
            .flatMap{ $0.url }
            .filter{ $0.hasPrefix("http") }
            .flatMap{ URL(string: $0) }
    }
    
    func prefere(orientation: Image.Orientation) -> [Image] {
        return sorted{ l, r -> Bool in
            if let lo = l.orientation, lo == orientation {
                return true
            }
            else if let ro = r.orientation, ro == orientation {
                return false
            }
            else {
                return true
            }
        }
    }
}
