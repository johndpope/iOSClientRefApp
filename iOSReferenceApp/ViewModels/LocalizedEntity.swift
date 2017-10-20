//
//  LocalizedEntity.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-20.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

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
