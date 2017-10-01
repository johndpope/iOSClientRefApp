//
//  CategoryViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-05-31.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class CategoryViewModel: AuthorizedEnvironment {
    typealias AssetType = Asset.AssetType
    
    var content: [AssetViewModel] {
        get {
            return Array(assets)
        }
    }
    fileprivate(set) var assets: Set<AssetViewModel> = Set()
    let type: AssetType
    let environment: Environment
    let sessionToken: SessionToken
    
    init(type: Asset.AssetType, environment: Environment, sessionToken: SessionToken, list: [AssetViewModel] = []) {
        self.type = type
        self.environment = environment
        self.sessionToken = sessionToken
        assets = Set(list)
    }
    
    lazy fileprivate var request: FetchAssetList = { [unowned self] in
        return FetchAsset(environment: self.environment)
            .list()
            .includeUserData(for: self.sessionToken)
//            .elasticSearch(query: "medias.drm:UNENCRYPTED AND medias.format:HLS")
            .elasticSearch(query: "(medias.drm:FAIRPLAY OR medias.drm:UNENCRYPTED) AND medias.format:HLS")
    }()
    
    fileprivate var loadedBatches: Set<Int> = []
    fileprivate var inProgressBatches: Set<Int> = []
}

extension CategoryViewModel {
    
    var batchSize: Int {
        return 2
    }
    
    func fetchMetadata(batch: Int, callback: @escaping (ExposureError?) -> Void) {
        guard !loadedBatches.contains(batch) else { return }
        guard !inProgressBatches.contains(batch) else { return }
        inProgressBatches.insert(batch)
        
        let type = self.type
        
        request
            .show(page: batch, spanning: batchSize)
            .filter(on: type)
            .filter(onlyPublished: false)
            .sort(on: ["-assetId"])
            .request()
            .response{ [unowned self] (exposure: ExposureResponse<AssetList>) in
                if let success = exposure.value {
                    self.processResponse(list: success, for: type)
                    self.inProgressBatches.remove(batch)
                    self.loadedBatches.insert(batch)
                    callback(nil)
                }
                
                if let error = exposure.error {
                    print(error)
                    self.inProgressBatches.remove(batch)
                }
        }
    }
    
    fileprivate func processResponse(list: AssetList, for type: AssetType) {
        guard let items = list.items else {
            // No valid assets
            return
        }
        
        let itemsArray = items
            .flatMap{ AssetViewModel(asset: $0 ) }
            .filter{ $0.type == type }

        itemsArray.forEach {
            assets.insert($0)
        }
    }
}

extension CategoryViewModel {
    var preferredCellSize: CGSize {
        return CGSize(width: 128, height: 96)
    }
    
    var preferredCellsPerRow: CGFloat {
        return 3
    }
    
    var previewCellPadding: CGFloat {
        return 5
    }
}

extension CategoryViewModel {
    var title: String {
        switch type {
        case .movie: return "Movies"
        case .tvShow: return "Tv Shows"
        case .episode: return "Episodes"
        case .clip: return "Clips"
        case .tvChannel: return "Tv Channels"
        case .ad: return "Advertisements"
        case .liveEvent: return "Live Events"
        case .other(type: _): return "Other"
        }
    }
}
