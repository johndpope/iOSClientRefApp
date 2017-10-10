//
//  AssetDetailsViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-06-01.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class AssetDetailsViewModel: AuthorizedEnvironment {
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
    
    func refreshAssetMetaData(callback: @escaping (ExposureError?) -> Void) {
        guard let assetId = asset.assetId else {
            return
        }
        
        FetchAsset(environment: environment)
            .filter(assetId: assetId)
            .includeUserData(for: sessionToken)
            .request()
            .validate()
            .response{ [weak self] (exposure: ExposureResponse<Asset>) in
                guard let weakSelf = self else {
                    return
                }
                
                if let success = exposure.value {
                    weakSelf.asset = success
                    callback(nil)
                    return
                }
                
                if let error = exposure.error {
                    callback(error)
                    return
                }
        }
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

extension AssetDetailsViewModel {
    var productionYear: String {
        return asset.productionYear != nil ? "\(asset.productionYear!)" : " "
    }
}

extension AssetDetailsViewModel {
    func anyParentalRating(locale: String) -> String? {
        if let localizedRating = localizedParentalRating(locale: locale), let rating = localizedRating.rating {
            return rating
        }
        return asset.parentalRatings?.first?.rating ?? " "
    }
    
    fileprivate func localizedParentalRating(locale: String) -> ParentalRating? {
        return asset
            .parentalRatings?
            .filter{ $0.country != nil ? $0.country! == locale : false }
            .first
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
