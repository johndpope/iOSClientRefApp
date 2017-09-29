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

extension AssetDetailsViewModel {
    struct LastViewedOffset {
        let currentOffset: String
        let progress: Float
        let duration: String
    }
    
    var lastViewedOffset: LastViewedOffset? {
        if let playHistory = asset.userData?.playHistory, let duration = asset.medias?.first?.durationMillis {
            let progress = Float(playHistory.lastViewedOffset)/Float(duration)
            return LastViewedOffset(currentOffset: stringFrom(milliseconds: playHistory.lastViewedOffset),
                                    progress: progress,
                                    duration: stringFrom(milliseconds: duration))
        }
        return nil
    }
    
    fileprivate func stringFrom(milliseconds: Int) -> String {
        let seconds = milliseconds / 1000
        if seconds < 60 {
            return "\(seconds) s"
        }
        else if seconds < 3600 {
            return "\((seconds % 3600)/60) m"
        }
        else {
            return "\(seconds / 3600) h : \((seconds % 3600)/60) m"
        }
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
