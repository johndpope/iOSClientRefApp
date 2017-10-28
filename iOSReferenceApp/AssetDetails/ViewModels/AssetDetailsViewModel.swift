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
    var asset: Asset
    
    var environment: Environment
    var sessionToken: SessionToken
    func authorize(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
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

// MARK: Production Year
extension AssetDetailsViewModel {
    var productionYear: String {
        return asset.productionYear != nil ? "\(asset.productionYear!)" : " "
    }
}

// MARK: Parental Rating
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

// MARK: Participants
extension AssetDetailsViewModel {
    struct ParticipantGroup {
        let function: String
        let names: [String]
    }
    
    func participantGroups() -> [ParticipantGroup] {
        let groups = asset.participants?.flatMap{ p -> (String, String)? in
            guard let function = p.function, let name = p.name else { return nil }
            return (function, name)
        }
        if let groups = groups {
            return Dictionary(grouping: groups) { $0.0 }
                .map{ ParticipantGroup(function: $0.key, names: $0.value.map{ $0.1 }) }
        }
        return []
    }
}

extension AssetDetailsViewModel: LocalizedAssetEntity {
    
}
