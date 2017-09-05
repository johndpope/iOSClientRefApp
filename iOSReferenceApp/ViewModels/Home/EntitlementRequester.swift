//
//  EntitlementRequester.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-06-02.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

protocol AuthorizedEnvironment {
    var environment: Environment { get }
    var sessionToken: SessionToken { get }
}

protocol EntitlementRequester: AuthorizedEnvironment {
    //var playRequest: PlayRequest { get }
}


extension EntitlementRequester {
    func request(vod assetId: String, callback: @escaping (PlaybackEntitlement?, ExposureError?) -> Void) {
        Entitlement(environment: environment,
                    sessionToken: sessionToken)
            .vod(assetId: assetId)
            .request()
            .validate()
            .response{ (exposure: ExposureResponse<PlaybackEntitlement>) in
                if let error = exposure.error {
                    callback(nil, error)
                }
                else if let success = exposure.value {
                    callback(success,nil)
                }
        }
    }
    
    func request(live channelId: String, callback: @escaping (PlaybackEntitlement?, ExposureError?) -> Void) {
        let entitlement = Entitlement(environment: environment,
                    sessionToken: sessionToken)
            .live(channelId: channelId)
        
        entitlement
            .request()
            .validate()
            .response{ (exposure: ExposureResponse<PlaybackEntitlement>) in
                if let error = exposure.error {
                    // Workaround until EMP-10023 is fixed
                    if case let .exposureResponse(reason: reason) = error, (reason.httpCode == 403 && reason.message == "NO_MEDIA_ON_CHANNEL") {
                        entitlement
                            .use(drm: .unencrypted)
                            .request()
                            .validate()
                            .response{ (exposure: ExposureResponse<PlaybackEntitlement>) in
                                if let error = exposure.error {
                                    callback(nil, error)
                                }
                                else if let success = exposure.value {
                                    callback(success, nil)
                                }
                        }
                    }
                    else {
                        callback(nil, error)
                    }
                }
                else if let success = exposure.value {
                    callback(success,nil)
                }
        }
    }
    
    func request(program programId: String, channel channelId: String, callback: @escaping (PlaybackEntitlement?, ExposureError?) -> Void) {
        let entitlement = Entitlement(environment: environment,
                    sessionToken: sessionToken)
            .live(channelId: channelId)
            .catchup(programId: programId)
        
        entitlement
            .request()
            .validate()
            .response{ (exposure: ExposureResponse<PlaybackEntitlement>) in
                if let error = exposure.error {
                    // Workaround until EMP-10023 is fixed
                    if case let .exposureResponse(reason: reason) = error, (reason.httpCode == 403 && reason.message == "NO_MEDIA_FOR_PROGRAM") {
                        entitlement
                            .use(drm: .unencrypted)
                            .request()
                            .validate()
                            .response{ (exposure: ExposureResponse<PlaybackEntitlement>) in
                                if let error = exposure.error {
                                    callback(nil, error)
                                }
                                else if let success = exposure.value {
                                    callback(success, nil)
                                }
                        }
                    }
                    else {
                        callback(nil, error)
                    }
                }
                else if let success = exposure.value {
                    callback(success, nil)
                }
        }
    }
}
