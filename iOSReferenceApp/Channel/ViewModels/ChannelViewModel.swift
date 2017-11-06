//
//  ChannelViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-06.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class ChannelViewModel {
    var asset: Asset!
    
    var environment: Environment
    var sessionToken: SessionToken
    
    init(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
}
