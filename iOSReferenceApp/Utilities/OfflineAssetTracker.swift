//
//  OfflineAssetTracker.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-05.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Download
import Exposure

// MARK: Fetch Asset
enum OfflineAssetTracker {
    static func offline(assetId: String) -> OfflineMediaAsset? {
        return offlineAssets()
            .filter{ $0.assetId == assetId }
            .first
    }
    
    fileprivate static func offlineAssets() -> [OfflineMediaAsset] {
        guard let localMedia = localMediaRecords else { return [] }
        return localMedia.map{ resolve(mediaRecord: $0) }
    }
}

extension OfflineAssetTracker {
    fileprivate static var localMediaRecords: [LocalMediaRecord]? {
        do {
            let logFile = try logFileURL()
            
            if !FileManager.default.fileExists(atPath: logFile.path) {
                return []
            }
            let data = try Data(contentsOf: logFile)
            
            let localMedia = try JSONDecoder().decode([LocalMediaRecord].self, from: data)
            
            localMedia.forEach{ print("📎 Local media id: \($0.assetId)") }
            return localMedia
        }
        catch {
            print("localMediaLog failed",error.localizedDescription)
            return nil
        }
    }
    
    fileprivate static func resolve(mediaRecord: LocalMediaRecord) -> OfflineMediaAsset {
        var bookmarkDataIsStale = false
        guard let urlBookmark = mediaRecord.urlBookmark else {
            return OfflineMediaAsset(assetId: mediaRecord.assetId, entitlement: mediaRecord.entitlement, url: nil)
        }
        
        do {
            guard let url = try URL(resolvingBookmarkData: urlBookmark, bookmarkDataIsStale: &bookmarkDataIsStale) else {
                return OfflineMediaAsset(assetId: mediaRecord.assetId, entitlement: mediaRecord.entitlement, url: nil)
                
            }
            
            guard !bookmarkDataIsStale else {
                return OfflineMediaAsset(assetId: mediaRecord.assetId, entitlement: mediaRecord.entitlement, url: nil)
            }
            
            return OfflineMediaAsset(assetId: mediaRecord.assetId, entitlement: mediaRecord.entitlement, url: url)
        }
        catch {
            return OfflineMediaAsset(assetId: mediaRecord.assetId, entitlement: mediaRecord.entitlement, url: nil)
        }
    }
}

// MARK: Directory
extension OfflineAssetTracker {
    fileprivate static var localMediaRecordsFile: String {
        return "localMediaRecords"
    }
    
    fileprivate static func logFileURL() throws -> URL {
        return try baseDirectory().appendingPathComponent(localMediaRecordsFile)
    }
    
    /// This directory should be reserved for analytics data.
    ///
    /// - returns: `URL` to the base directory
    /// - throws: `FileManager` error
    fileprivate static func baseDirectory() throws -> URL {
        return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("emp")
            .appendingPathComponent("offlineMedia")
    }
}

extension OfflineAssetTracker {
    static func save(assetId: String, entitlement: PlaybackEntitlement, url: URL?) {
        do {
            let record = try LocalMediaRecord(assetId: assetId, entitlement: entitlement, completedAt: url)
            save(localRecord: record)
        }
        catch {
            print("🚨 Unable to bookmark local media record \(assetId): ",error.localizedDescription)
        }
    }
    
    /// This method will ensure `LocalMediaLog` has a unique list of downloads with respect to `assetId`
    fileprivate static func save(localRecord: LocalMediaRecord) {
        let localMedia = localMediaRecords ?? []
        // Delte any currently stored OfflineMediaAssets with `localRecord.assetId as they are considered "duplicate"
        var filteredLog = localMedia
            .filter{ record -> Bool in
                if record.assetId == localRecord.assetId {
                    remove(localRecordId: record.assetId)
                    return false
                }
                else {
                    return true
                }
        }
        
        filteredLog.append(localRecord)
        save(mediaLog: filteredLog)
    }
    
    fileprivate static func save(mediaLog: [LocalMediaRecord]) {
        do {
            let logURL = try baseDirectory()
            
            let data = try JSONEncoder().encode(mediaLog)
            try data.persist(as: localMediaRecordsFile, at: logURL)
        }
        catch {
            print("save(mediaLog:) failed",error.localizedDescription)
        }
    }
}

extension OfflineAssetTracker {
    static func remove(localRecordId: String) {
        guard let localMedia = localMediaRecords else { return }
        
        // Bookmark may contain a data url, if so clear it
        clear(dataFor: localMedia.filter{ $0.assetId == localRecordId }.first)
        
        /// Update and save new log
        let newLog = localMedia.filter{ $0.assetId != localRecordId }
        save(mediaLog: newLog)
    }
    
    static private func clear(dataFor media: LocalMediaRecord?) {
        if let urlBookmark = media?.urlBookmark {
            var bookmarkDataIsStale = false
            if let url = try? URL(resolvingBookmarkData: urlBookmark, bookmarkDataIsStale: &bookmarkDataIsStale) {
                if let url = url, !bookmarkDataIsStale {
                    clear(dataAt: url)
                }
            }
        }
    }
    
    static func clear(dataAt url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            print("✅ OfflineAssetTracker. Cleaned up local media")
        }
        catch {
            print("🚨 OfflineAssetTracker. Failed to clean local media: ",error.localizedDescription)
        }
    }
}
