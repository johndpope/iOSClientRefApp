//
//  PresetViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-05-30.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class PresetViewModel: AuthorizedEnvironment {
    // MARK: Basics
    let credentials: Credentials
    
    let sampleAssets: [SampleAssetConfig]
    
    fileprivate(set) var categories: [CategoryViewModel] = []
    
    init(credentials: Credentials, environment: Environment, sampleAssets: [SampleAssetConfig]) {
        self.credentials = credentials
        self.environment = environment
        self.sampleAssets = sampleAssets
    }
    
    convenience init(sessionToken: SessionToken, environment: Environment, sampleAssets: [SampleAssetConfig]) {
        let cred = Credentials(sessionToken: sessionToken,
                               crmToken: nil,
                               accountId: nil,
                               expiration: nil,
                               accountStatus: nil)
        
        self.init(credentials: cred,
                  environment: environment,
                  sampleAssets: sampleAssets)
    }
    
    // MARK: AuthorizedEnvironment
    let environment: Environment
    var sessionToken: SessionToken {
        return credentials.sessionToken
    }
}

// MARK: PreviewAssetCellConfig
extension PresetViewModel: PreviewAssetCellConfig {
    func rowHeight(index: Int) -> CGFloat {
        let category = categories[index]
        return (category.preferredCellSize.height + 2*category.previewCellPadding)
    }
}

// MARK: - Fetch Metadata
extension PresetViewModel {
    // MARK: Exposure Assets
    func fetchMetadata(callback: @escaping (ExposureError?) -> Void) {
        FetchAsset(environment: environment)
            .list()
            //.elasticSearch(query: "medias.drm:FAIRPLAY AND medias.format:HLS")
            .filter(onlyAssetIds: sampleAssets.map{ $0.assetId })
            .show(page: 1, spanning: sampleAssets.count)
            .request()
            .response{ [unowned self] (exposure: ExposureResponse<AssetList>) in
                if let success = exposure.value {
                    self.processResponse(list: success)
                    callback(nil)
                }
                
                if let error = exposure.error {
                    print(error)
                }
        }
    }
    
    fileprivate func processResponse(list: AssetList) {
        guard let items = list.items else {
            // No valid assets
            categories.removeAll()
            return
        }
        
        categories = items
            .flatMap{ AssetViewModel(asset: $0 ) }
            .categorise{ $0.type }
            .filter{ $0.value.count > 0 }
            .map{ CategoryViewModel(type: $0.key, environment: environment, list: $0.value) }
    }
}



