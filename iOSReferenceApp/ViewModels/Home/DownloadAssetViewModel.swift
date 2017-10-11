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
                
                self?.handle(entitlement: entitlement, assetId: assetId) { task, error in
                    callback(task, entitlement, error)
                }
        }
    }
    
    fileprivate func handle(entitlement: PlaybackEntitlement, assetId: String, callback: (DownloadTask?, DownloadAssetError?) -> Void) {
        let bps = selectedBitrate?.bitrate != nil ? selectedBitrate!.bitrate!*1000 : nil
        do {
            if #available(iOS 10.0, *) {
                task = try Downloader
                    .download(entitlement: entitlement, assetId: assetId)
                    .use(bitrate: bps)
                callback(task, nil)
            } else {
                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as! URL
                let destinationUrl = documentsUrl.appendingPathComponent("\(assetId).m3u8")
                
                task = try Downloader
                    .download(entitlement: entitlement, assetId: assetId, to: destinationUrl)
                    .use(bitrate: bps)
                callback(task, nil)
            }
        }
        catch {
            callback(nil, .download(error: error as! DownloadError))
        }
    }
}

extension DownloadAssetViewModel {
    var isRunning: Bool {
        return state == .running
    }
    
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
        guard let bitrates = availableBitrates, !bitrates.isEmpty else { return }
        selectedBitrate = bitrates[index]
    }
    
    var selectedQualityIndex: Int? {
        guard let selectedBitrate = selectedBitrate else { return nil }
        guard let availableBitrates = availableBitrates else { return nil }
        return availableBitrates.index(of: selectedBitrate)
        
    }
    
    var downloadQualityOptions: Int? {
        return availableBitrates?.count
    }
    
    var hasQualityOptions: Bool {
        return availableBitrates != nil ? !availableBitrates!.isEmpty : false
    }
    
    struct DownloadQuality {
        let bitrate: String
        let size: String
    }
    
    func downloadQuality(for index: Int) -> DownloadQuality {
        guard let bitrates = availableBitrates, !bitrates.isEmpty else {
            return DownloadQuality(bitrate: "n/a", size: "n/a")
        }
        return downloadQuality(from: bitrates[index])
    }
    
    private func downloadQuality(from downloadBitrate: DownloadValidation.Bitrate) -> DownloadQuality {
        return DownloadQuality(bitrate: bitrate(for: downloadBitrate.bitrate),
                               size: size(for: downloadBitrate.size))
    }
    
    internal func downloadedSize(for progress: Double) -> String {
        guard let bytes = selectedBitrate?.size else { return "n/a" }
        let progressBytes = Int64(Double(bytes)*progress)
        return size(for: progressBytes)
    }
    
    internal func size(for bytes: Int64?) -> String {
        guard let bytes = bytes else { return "n/a" }
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: ByteCountFormatter.CountStyle.file)
    }
    
    internal func bitrate(for kbps: Int64?) -> String {
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

extension DownloadAssetViewModel {
    func offline(assetId: String) -> OfflineMediaAsset? {
        return OfflineAssetTracker.offline(assetId: assetId)
    }
    
    func save(assetId: String, entitlement: PlaybackEntitlement, url: URL?) {
        OfflineAssetTracker.save(assetId: assetId, entitlement: entitlement, url: url)
    }
    
    func remove(assetId: String, clearing url: URL? = nil) {
        OfflineAssetTracker.remove(localRecordId: assetId)
        if let url = url {
            OfflineAssetTracker.clear(dataAt: url)
        }
    }
}


internal struct LocalMediaRecord: Codable {
    /// URL encoded as bookmark data
    var urlBookmark: Data? {
        switch downloadState {
        case .completed(urlBookmark: let data): return data
        case .inProgress: return nil
        }
    }

    /// State
    let downloadState: DownloadState

    /// Id for the asset at `bookmarkURL`
    let assetId: String
    
    /// Related entitlement
    let entitlement: PlaybackEntitlement
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        assetId = try container.decode(String.self, forKey: .assetId)
        entitlement = try container.decode(PlaybackEntitlement.self, forKey: .entitlement)

        if let data = try container.decodeIfPresent(Data.self, forKey: .downloadState) {
            downloadState = .completed(urlBookmark: data)
        }
        else {
            downloadState = .inProgress
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(assetId, forKey: .assetId)
        try container.encode(entitlement, forKey: .entitlement)

        switch downloadState {
        case .completed(urlBookmark: let data): try container.encode(data, forKey: .downloadState)
        default: return
        }
    }

    internal init(assetId: String, entitlement: PlaybackEntitlement, completedAt location: URL?) throws {
        self.assetId = assetId
        self.entitlement = entitlement
        
        if let data = try location?.bookmarkData() {
            downloadState = .completed(urlBookmark: data)
        }
        else {
            downloadState = .inProgress
        }
    }

    internal enum DownloadState {

        /// URL encoded as bookmark data
        case completed(urlBookmark: Data)

        /// No destination might have been set
        case inProgress
    }

    internal enum CodingKeys: String, CodingKey {
        case downloadState
        case assetId
        case entitlement
    }
}


extension Data {
    /// Convenience function for persisting a `Data` blob through `FileManager`.
    ///
    /// - parameter filename: Name of the file, including extension
    /// - parameter directoryUrl: `URL` to the storage directory
    /// - throws: `FileManager` related `Error` or `Data` related error in the *Cocoa Domain*
    internal func persist(as filename: String, at directoryUrl: URL) throws {
        if !FileManager.default.fileExists(atPath: directoryUrl.path) {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        try self.write(to: directoryUrl.appendingPathComponent(filename))
    }
}
