//
//  CustomerConfig.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-03-27.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

struct CustomerConfig: Decodable {
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
        
        init(persistenceString: String) {
            switch persistenceString {
            case "anonymous": self = .anonymous
            case "mfa": self = .login(username: "", password: "", mfa: true)
            case "login": self = .login(username: "", password: "", mfa: false)
            default: self = .login(username: "", password: "", mfa: false)
            }
        }
        
        var persistenceString: String {
            switch self {
            case .anonymous: return "anonymous"
            case .login(username: _, password: _, mfa: let mfa): return mfa ? "mfa":"login"
            }
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        customer = try container.decode(String.self, forKey: .customer)
        businessUnit = try container.decode(String.self, forKey: .businessUnit)
        
        if let anonymous = try container.decodeIfPresent(Bool.self, forKey: .anonymous), anonymous {
            presetMethod = .anonymous
        }
        else if let username = try container.decodeIfPresent(String.self, forKey: .defaultUsername), let password = try container.decodeIfPresent(String.self, forKey: .defaultPassword) {
            let mfa = try container.decodeIfPresent(Bool.self, forKey: .mfa) ?? false
            presetMethod = .login(username: username, password: password, mfa: mfa)
        }
        else {
            presetMethod = nil
        }
    }
    
    internal enum CodingKeys: String, CodingKey {
        case name
        case customer
        case businessUnit
        case anonymous
        case defaultUsername
        case defaultPassword
        case mfa
    }
}

extension CustomerConfig {
    var pickerModelTitle: String {
        return name + " - " + (presetMethod?.pickerModelTitle ?? "")
    }
}
