//
//  CategoryViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-05-31.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class CategoryViewModel {
    typealias AssetType = Asset.AssetType
    
    fileprivate(set) var content: [AssetViewModel] = []
    let type: AssetType
    let environment: Environment
    
    init(type: Asset.AssetType, environment: Environment, list: [AssetViewModel] = []) {
        self.type = type
        self.environment = environment
        content = list.filter{ $0.type == type }
    }
    
    lazy fileprivate var request: FetchAssetList = { [unowned self] in
        return FetchAsset(environment: self.environment)
            .list()
            .elasticSearch(query: "(medias.drm:FAIRPLAY OR medias.drm:UNENCRYPTED) AND medias.format:HLS")
    }()
    
    fileprivate var loadedBatches: Set<Int> = []
    fileprivate var inProgressBatches: Set<Int> = []
}

extension CategoryViewModel {
    func append(assets: [AssetViewModel]) {
        content.append(contentsOf: assets)
    }
    
    var batchSize: Int {
        return 50
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
        
        let assets = items
            .flatMap{ AssetViewModel(asset: $0 ) }
            .filter{ $0.type == type }
        
        content.append(contentsOf: assets)
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
