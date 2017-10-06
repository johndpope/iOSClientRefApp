//
//  OfflineMediaAsset.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-06.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Download
import AVFoundation

public struct OfflineMediaAsset {
    //    /// Returns the download task if download is not complete
    //    public func downloadTask(callback: @escaping (AVAssetDownloadTask?) -> Void) {
    //        SessionManager
    //            .default
    //            .task(assetId: self.assetId,
    //                  callback: callback)
    //    }
    
    public init(assetId: String, url: URL?) {
        self.assetId = assetId
        if let url = url {
            self.urlAsset = AVURLAsset(url: url)
        }
        else {
            self.urlAsset = nil
        }
    }
    
    public let assetId: String
    public let urlAsset: AVURLAsset?
    
    //    public func resumeDownload() -> ResumedDownloadTask {
    //        guard urlAsset == nil else {
    //            return ResumedDownloadTask(assetId: assetId, error: .alreadyDownloaded(assetId: assetId, location: urlAsset!.url))
    //        }
    //
    //        return ResumedDownloadTask(assetId: assetId)
    //    }
    
//        public func hasActiveTask(callback: @escaping (Bool) -> Void) {
//            SessionManager
//                .default
//                .task(assetId: assetId) { task in
//                    if task == nil {
//                        callback(false)
//                        return
//                    }
//                    callback(true)
//                    return
//            }
//        }
    
    public func state(callback: @escaping (State) -> Void) {
        guard let urlAsset = urlAsset else {
            callback(.notPlayable)
            return
        }
        
        //        if #available(iOS 10.0, *) {
        //            print("PlayableOffline: ",urlAsset.url,urlAsset.assetCache?.isPlayableOffline)
        //            if let assetCache = urlAsset.assetCache, assetCache.isPlayableOffline {
        //                callback(.completed)
        //                return
        //            }
        //        }
        
        urlAsset.loadValuesAsynchronously(forKeys: ["playable"]) {
            DispatchQueue.main.async {
                
                // Check for any issues preparing the loaded values
                var error: NSError?
                if urlAsset.statusOfValue(forKey: "playable", error: &error) == .loaded {
                    if urlAsset.isPlayable {
                        callback(.completed)
                    }
                    else {
                        callback(.notPlayable)
                    }
                }
                else {
                    callback(.notPlayable)
                }
            }
        }
    }
    
    public enum State {
        case completed
        case notPlayable
    }
}
