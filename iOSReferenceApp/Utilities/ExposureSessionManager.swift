//
//  ExposureSessionManager.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-20.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class ExposureSessionManager {
    static let shared = ExposureSessionManager()
    
    let manager = SessionManager<ExposureDownloadTask>()
}
