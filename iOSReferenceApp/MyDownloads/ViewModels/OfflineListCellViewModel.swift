//
//  OfflineListCellViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-19.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure
import Download

class OfflineListCellViewModel {
    let offlineAsset: OfflineMediaAsset
    var asset: Asset?
    
    var brand: Branding.ColorScheme = Branding.ColorScheme.default
    
    init(offlineAsset: OfflineMediaAsset, metaData: Asset?) {
        self.offlineAsset = offlineAsset
        self.asset = metaData
    }
    
    var downloadSize: String? {
        guard let url = offlineAsset.urlAsset?.url else { return "" }
        guard let bytes = try? FileManager.default.allocatedSizeOfDirectory(atUrl: url) else { return "" }
        return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: ByteCountFormatter.CountStyle.file)
    }
    
    var expiration: String? {
        return offlineAsset.entitlement?.licenseExpiration
    }
    
    var preferedCellHeight: CGFloat {
        return preferredThumbnailSize.height - 2*2
    }
    
    var preferredThumbnailSize: CGSize {
        return CGSize(width: 54, height: 81)
    }
}

extension OfflineListCellViewModel: LocalizedEntity {
    var locales: [String] {
        return asset?
            .localized?
            .flatMap{ $0.locale } ?? []
    }
    
    func localizedData(locale: String) -> LocalizedData? {
        return asset?
            .localized?
            .filter{ $0.locale == locale }
            .first
    }
    
    func localizations() -> [LocalizedData] {
        return asset?.localized ?? []
    }
    
    func anyTitle(locale: String) -> String {
        if let title = title(locale: locale), title != "" { return title }
        else if let originalTitle = asset?.originalTitle, originalTitle != "" { return originalTitle }
        else if let assetId = asset?.assetId { return assetId }
        return "NO TITIE"
    }
    
    func anyDescription(locale: String) -> String {
        if let description = localizedData(locale: locale)?.allDescriptions().last {
            return description
        }
        return localizations().flatMap{ $0.allDescriptions() }.last ?? ""
    }
}
