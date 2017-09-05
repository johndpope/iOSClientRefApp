//
//  SampleAssetConfig.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-05-30.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SampleAssetConfig {
    let name: String
    let description: String
    let assetId: String
    let live: Bool
    
    init(name: String, description: String, assetId: String, live: Bool = false) {
        self.name = name
        self.description = description
        self.assetId = assetId
        self.live = live
    }
    
    init?(json: JSON) {
        guard let name = json["name"].string,
            let assetId = json["assetId"].string else { return nil }
        
        self.name = name
        self.assetId = assetId
        description = json["description"].string ?? ""
        live = json["live"].bool ?? false
    }
}
