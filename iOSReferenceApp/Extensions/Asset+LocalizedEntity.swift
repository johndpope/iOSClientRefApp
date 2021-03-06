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
        if let title = title(locale: locale), title != "" { return title }
        else if let originalTitle = originalTitle, originalTitle != "" { return originalTitle }
        return assetId
    }
    
    func anyDescription(locale: String) -> String {
        if let description = localizedData(locale: locale)?.allDescriptions().last {
            return description
        }
        return localizations().flatMap{ $0.allDescriptions() }.last ?? ""
    }
}

extension Array where Element == LocalizedData {
    func title(locale: String) -> String? {
        if let result = localizedData(locale: locale)?.title {
            return result
        }
        return flatMap{ $0.title }.first
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
    
    var locales: [String] {
        return flatMap{ $0.locale }
    }
    
    func localizedData(locale: String) -> LocalizedData? {
        return filter{ $0.locale == locale }.first
    }
    
    func anyTitle(locale: String) -> String {
        if let title = title(locale: locale), title != "" { return title }
        return "NO TITIE"
    }
    
    func anyDescription(locale: String) -> String {
        if let description = localizedData(locale: locale)?.allDescriptions().last {
            return description
        }
        return flatMap{ $0.allDescriptions() }.last ?? ""
    }
}
