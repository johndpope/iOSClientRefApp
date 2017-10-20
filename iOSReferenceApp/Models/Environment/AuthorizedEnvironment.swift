//
//  AuthorizedEnvironment.swift
//  iOSReferenceApp
//
//  Created by Viktor Gardart on 2017-09-11.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

protocol AuthorizedEnvironment {
    var environment: Environment { get }
    var sessionToken: SessionToken { get }
    func authorize(environment: Environment, sessionToken: SessionToken)
}
