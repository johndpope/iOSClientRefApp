//
//  OfflineListCellViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-19.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure
import Download

class OfflineListCellViewModel {
    
    let offlineAsset: OfflineMediaAsset
    
    init(offlineAsset: OfflineMediaAsset) {
        self.offlineAsset = offlineAsset
    }
    
    var title: String {
        return offlineAsset.assetId
    }
    
    var downloadSize: String? {
        guard let url = offlineAsset.urlAsset?.url else { return "" }
        guard let bytes = try? FileManager.default.allocatedSizeOfDirectory(atUrl: url) else { return "" }
        return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: ByteCountFormatter.CountStyle.file)
    }
    
    var expiration: String? {
        return offlineAsset.entitlement?.licenseExpiration
    }
    
    var preferedHeight: CGFloat {
        return 85
    }
}
