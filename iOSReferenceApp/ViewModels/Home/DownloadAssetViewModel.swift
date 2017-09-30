//
//  DownloadAssetViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-09-30.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure
import Download

class DownloadAssetViewModel: AuthorizedEnvironment {
    fileprivate var task: DownloadTask?
    
    fileprivate(set) var environment: Environment
    fileprivate(set) var sessionToken: SessionToken
    
    fileprivate var availableBitrates: [DownloadValidation.Bitrate]?
    fileprivate var selectedBitrate: DownloadValidation.Bitrate?
    
    init(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
}

extension DownloadAssetViewModel {
    enum DownloadAssetError: Error {
        case exposure(error: ExposureError)
        case download(error: DownloadError)
    }
}

extension DownloadAssetViewModel {
    func download(assetId: String, callback: @escaping (DownloadTask?, PlaybackEntitlement?, DownloadAssetError?) -> Void) {
        Entitlement(environment: environment,
                    sessionToken: sessionToken)
            .download(assetId: assetId)
            .use(drm: .fairplay)
            .request()
            .validate()
            .response{ [weak self] (res: ExposureResponse<PlaybackEntitlement>) in
                guard let entitlement = res.value else {
                    callback(nil, nil, .exposure(error: res.error!))
                    return
                }
                
                self?.handle(entitlement: entitlement, named: assetId) { task, error in
                    callback(task, entitlement, error)
                }
        }
    }
    
    fileprivate func handle(entitlement: PlaybackEntitlement, named name: String, callback: (DownloadTask?, DownloadAssetError?) -> Void) {
        do {
            if #available(iOS 10.0, *) {
                task = try Downloader.download(entitlement: entitlement, named: name)
                callback(task, nil)
            } else {
                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as! URL
                let destinationUrl = documentsUrl.appendingPathComponent("\(name).m3u8")
                
                task = try Downloader.download(entitlement: entitlement, to: destinationUrl)
            }
        }
        catch {
            callback(nil, .download(error: error as! DownloadError))
        }
    }
}

extension DownloadAssetViewModel {
    var state: DownloadTask.State {
        guard let task = task else { return .notStarted }
        return task.state
    }
    
    func resume() {
        task?.resume()
    }
    
    func pause() {
        task?.suspend()
    }
    
    func cancel() {
        task?.cancel()
    }
}

extension DownloadAssetViewModel {
    func refreshDownloadMetadata(for assetId: String, callback: @escaping (Bool) -> Void) {
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
                        self?.availableBitrates = result.bitrates?.filter{ $0.bitrate != nil && $0.bitrate! > 0 && $0.size != nil && $0.size! > 0 }
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


