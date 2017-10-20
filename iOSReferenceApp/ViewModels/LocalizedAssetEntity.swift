//
//  LocalizedAssetEntity.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-20.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure
protocol LocalizedAssetEntity: LocalizedEntity {
    var asset: Asset { get }
}

extension LocalizedAssetEntity {
    var locales: [String] {
        return asset.locales
    }
    
    func localizedData(locale: String) -> LocalizedData? {
        return asset.localizedData(locale: locale)
    }
    
    func localizations() -> [LocalizedData] {
        return asset.localizations()
    }
    
    func anyTitle(locale: String) -> String {
        return asset.anyTitle(locale: locale)
    }
    
    func anyDescription(locale: String) -> String {
        return asset.anyDescription(locale: locale)
    }
}
