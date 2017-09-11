//
//  AssetDetailsViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-06-01.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class AssetDetailsViewModel {
    fileprivate(set) var asset: Asset
    fileprivate(set) var environment: Environment
    fileprivate(set) var sessionToken: SessionToken
    
    init(asset: Asset, environment: Environment, sessionToken: SessionToken) {
        self.asset = asset
        self.environment = environment
        self.sessionToken = sessionToken
    }
}

extension AssetDetailsViewModel: LocalizedEntity {
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
