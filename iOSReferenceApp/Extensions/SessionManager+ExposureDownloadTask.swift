//
//  SessionManager+ExposureDownloadTask.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-20.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure
import Download
import ExposureDownload

extension SessionManager where T == ExposureDownloadTask {
    func offlineAssetsWithMetaData() -> [(OfflineMediaAsset, Asset?)] {
        return offlineAssets().map{ return ($0, retrieveMetaData(for: $0.assetId)) }
    }
    
    func removeMetaData(for asset: Asset) {
        let all = retrieveMetaData() ?? []
        
        let filtered = all.filter{ $0.assetId != asset.assetId }
        
        persist(metaData: filtered)
    }
    
    func storeMetaData(for asset: Asset) {
        let all = retrieveMetaData() ?? []
        
        var filtered = all.filter{ $0.assetId != asset.assetId }
        filtered.append(asset)
        
        persist(metaData: filtered)
    }
    
    private func persist(metaData: [Asset]) {
        do {
            let dirURL = try baseDirectory()
            
            let data = try JSONEncoder().encode(metaData)
            try data.persist(as: metaDataStorageFileName, at: dirURL)
        }
        catch {
            print("save(mediaLog:) failed",error.localizedDescription)
        }
    }
    
    func retrieveMetaData(for assetId: String) -> Asset? {
        return retrieveMetaData()?
            .filter{ $0.assetId == assetId }
            .first
    }
    
    func loadMetaData(for assetIds: Set<String>) -> [Asset] {
        return retrieveMetaData()?
            .filter{ asset -> Bool in
                return assetIds.contains(asset.assetId)
            } ?? []
    }
    
    func retrieveMetaData() -> [Asset]? {
        do {
            let fileUrl = try metaDataStorageURL()
            
            if !FileManager.default.fileExists(atPath: fileUrl.path) {
                return []
            }
            let data = try Data(contentsOf: fileUrl)
            
            let localMedia = try JSONDecoder().decode([Asset].self, from: data)
            
            return localMedia
        }
        catch {
            print("retrieveMetaData failed",error.localizedDescription)
            return nil
        }
    }
    
    fileprivate var metaDataStorageFileName: String {
        return "metaDataStorage"
    }
    
    fileprivate func metaDataStorageURL() throws -> URL {
        return try baseDirectory().appendingPathComponent(metaDataStorageFileName)
    }
    
    internal func baseDirectory() throws -> URL {
        return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("emp")
            .appendingPathComponent("refApp")
            .appendingPathComponent("offlineMedia")
    }
}
