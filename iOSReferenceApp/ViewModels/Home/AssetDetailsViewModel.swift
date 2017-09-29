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
    
    fileprivate var availableBitrates: [DownloadValidation.Bitrate]?
    fileprivate var selectedBitrate: DownloadValidation.Bitrate?
    
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
    
    func refreshAssetMetaData(callback: @escaping (Bool) -> Void) {
        guard let assetId = asset.assetId else {
            callback(false)
            return
        }
        FetchAsset(environment: environment)
            .filter(assetId: assetId)
            .includeUserData(for: sessionToken)
            .request()
            .response{ [weak self] (exposure: ExposureResponse<Asset>) in
                guard let weakSelf = self else {
                    callback(false)
                    return
                }
                
                if let success = exposure.value {
                    weakSelf.asset = success
                    callback(true)
                    return
                }
                
                if let error = exposure.error {
                    callback(false)
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
    func refreshDownloadMetadata(callback: @escaping (Bool) -> Void) {
        guard let assetId = asset.assetId else {
            callback(false)
            return
        }
        
        Entitlement(environment: environment,
                    sessionToken: sessionToken)
            .validate(downloadId: assetId)
            .use(drm: .fairplay)
            .request()
            .validate()
            .response{ [weak self] (exposure: ExposureResponse<DownloadValidation>) in
                if let result = exposure.value {
                    if case .success = result.status {
                        // Temporary hack to filter out 0/0 Bitrate entries
                        let t = result.bitrates?.filter{ $0.bitrate != nil && $0.bitrate! > 0 && $0.size != nil && $0.size! > 0 }
                        self?.availableBitrates = t
                        callback(true)
                        return
                    }
                    else {
                        callback(false)
                    }
                }
                else { callback(false) }
        }
    }
    
    func select(downloadQuality index: Int) {
        selectedBitrate = availableBitrates?[index]
    }
    
    var downloadQualityOptions: Int {
        return availableBitrates?.count ?? 0
    }
    
    struct DownloadQuality {
        let bitrate: String
        let size: String
    }
    
    func downloadQuality(for index: Int) -> DownloadQuality {
        print("downloadQuality",index)
        return downloadQuality(from: availableBitrates?[index])
    }
    
    private func downloadQuality(from downloadBitrate: DownloadValidation.Bitrate?) -> DownloadQuality {
        return DownloadQuality(bitrate: bitrate(for: downloadBitrate?.bitrate),
                               size: size(for: downloadBitrate?.size))
    }
    
    private func size(for bytes: Int64?) -> String {
        guard let bytes = bytes else { return "n/a" }
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: ByteCountFormatter.CountStyle.file)
    }
    
    private func bitrate(for kbps: Int64?) -> String {
        // LD 240p 3G Mobile @ H.264 baseline profile 350 kbps (3 MB/minute)
        // LD 360p 4G Mobile @ H.264 main profile 700 kbps (6 MB/minute)
        // SD 480p WiFi @ H.264 main profile 1200 kbps (10 MB/minute)
        // HD 720p @ H.264 high profile 2500 kbps (20 MB/minute)
        // HD 1080p @ H.264 high profile 5000 kbps (35 MB/minute)
        
        // 480p (720x480): 750-1000kbps
        // 720p (1280x720): 1500-3000kbps
        // 1080p (1920x1080): 3000-5000kbps+
        
        //                 240p       360p        480p        720p        1080p
        // Resolution      426 x 240   640 x 360   854x480     1280x720    1920x1080
        // Video Bitrates
        // Maximum         700 Kbps    1000 Kbps   2000 Kbps   4000 Kbps   6000 Kbps
        // Recommended     400 Kbps    750 Kbps    1000 Kbps   2500 Kbps   4500 Kbps
        // Minimum         300 Kbps    400 Kbps    500 Kbps    1500 Kbps   3000 Kbps
        guard let kbps = kbps else {
            return "n/a"
        }
        
        if kbps < 550 {
            return "240p"
        }
        else if kbps < 850 {
            return "360p"
        }
        else if kbps < 1500 {
            return "480p"
        }
        else if kbps < 3000 {
            return "720p"
        }
        else if kbps < 6000 {
            return "1080p"
        }
        else if kbps < 13000 {
            return "1440p"
        }
        else {
            return "4k"
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
