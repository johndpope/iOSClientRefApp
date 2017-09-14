//
//  CustomerConfig.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-03-27.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import SwiftyJSON

struct CustomerConfig {
    let name: String
    let customer: String
    let businessUnit: String
    let presetMethod: PresetMethod?
    
    init(name: String, customer: String, businessUnit: String, presetMethod: PresetMethod? = nil) {
        self.name = name
        self.customer = customer
        self.businessUnit = businessUnit
        self.presetMethod = presetMethod
    }
    
    enum PresetMethod {
        case anonymous
        case login(username: String, password: String, mfa: Bool)
        
        var pickerModelTitle: String {
            switch self {
            case .anonymous: return "Anonymous"
            case .login(username: let username, password: _, mfa: let mfa): return "\(username)" + (mfa ? "[MFA]" : "")
            }
        }
        
        init?(json: JSON) {
            if json["anonymous"].bool != nil {
                self = .anonymous
            }
            else if let username = json["defaultUsername"].string,
                let password = json["defaultPassword"].string {
                if let mfa = json["mfa"].bool {
                    self = .login(username: username, password: password, mfa: mfa)
                }
                else {
                    self = .login(username: username, password: password, mfa: false)
                }
            }
            else {
                return nil
            }
        }
    }
}

extension CustomerConfig {
    var pickerModelTitle: String {
        return name + " - " + (presetMethod?.pickerModelTitle ?? "")
    }
}

extension CustomerConfig {
    init?(json: JSON) {
        guard let name = json["name"].string,
            let customer = json["customer"].string,
            let businessUnit = json["businessUnit"].string else { return nil }
        
        self.name = name
        self.customer = customer
        self.businessUnit = businessUnit
        presetMethod = PresetMethod(json: json)
    }
}
