//
//  OfflineListViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-20.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class OfflineListViewModel: AuthorizedEnvironment {
    var environment: Environment
    var sessionToken: SessionToken
    func authorize(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
    init(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
    func fetchContent() -> [OfflineListCellViewModel] {
        let t: Asset!
        
        return ExposureSessionManager
            .shared
            .manager
            .offlineAssetsWithMetaData()
            .sorted{
                if let a0 = $0.1, let a1 = $1.1 {
                    return a0.anyTitle(locale: "en") < a1.anyTitle(locale: "en")
                }
                else {
                    return $0.0.assetId < $1.0.assetId
                }
            }
            .map{ OfflineListCellViewModel(offlineAsset: $0.0, metaData: $0.1) }
    }
}
