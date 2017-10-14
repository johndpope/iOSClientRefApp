//
//  DynamicCustomerConfig.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-13.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

struct DynamicCustomerConfig {
    let serviceName: String?
    let serviceSlogan: String?
    let logoUrl: String?
    
    let mfaRequired: Bool
    let lastViewed: Bool
    let carouselGroupId: String?
//{
//    "serviceName": "Enigma TV",
//    "serviceSlogan": "Enigmatic Video Streaming",
//    "logoUrl": "https://emp-demo.azurewebsites.net/enigma-tv/images/logo_white.png",
//    "freeProducts": [
//    "EnigmaFVOD_enigma",
//    "ch03_enigma"
//    ],
//    "mfaRequired": true,
//    "lastViewed": true,
//    "carouselGroupId": "basicCarousels"
//    }
    
    init?(json: AnyJSONType) {
        guard let dataArray = json.jsonValue as? [AnyJSONType],
            let configData = dataArray.first?.jsonValue as? [String: AnyJSONType] else {
                return nil
        }
        
        serviceName = configData["serviceName"]?.jsonValue as? String
        serviceSlogan = configData["serviceSlogan"]?.jsonValue as? String
        logoUrl = configData["logoUrl"]?.jsonValue as? String
        mfaRequired = configData["mfaRequired"]?.jsonValue as? Bool ?? false
        lastViewed = configData["lastViewed"]?.jsonValue as? Bool ?? false
        carouselGroupId = configData["carouselGroupId"]?.jsonValue as? String
    }
}
