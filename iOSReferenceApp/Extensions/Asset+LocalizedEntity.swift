//
//  Asset+LocalizedEntity.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-20.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

extension Asset: LocalizedEntity {
    var locales: [String] {
        return localized?.flatMap{ $0.locale } ?? []
    }
    
    func localizedData(locale: String) -> LocalizedData? {
        return localized?.filter{ $0.locale == locale }.first
    }
    
    func localizations() -> [LocalizedData] {
        return localized ?? []
    }
    
    func anyTitle(locale: String) -> String {
        if let title = title(locale: locale) { return title }
        else if let originalTitle = originalTitle { return originalTitle }
        else if let assetId = assetId { return assetId }
        return "NO TITIE"
    }
    
    func anyDescription(locale: String) -> String {
        if let description = localizedData(locale: locale)?.allDescriptions().last {
            return description
        }
        return localizations().flatMap{ $0.allDescriptions() }.last ?? ""
    }
}
