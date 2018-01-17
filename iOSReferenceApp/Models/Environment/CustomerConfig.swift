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
    let usesMfa: Bool?
    let defaultUsername: String?
    let defaultPassword: String?
    
    init(name: String, customer: String, businessUnit: String, usesMfa: Bool = false, defaultUsername: String? = nil, defaultPassword: String? = nil) {
        self.name = name
        self.customer = customer
        self.businessUnit = businessUnit
        self.usesMfa = usesMfa
        self.defaultUsername = defaultUsername
        self.defaultPassword = defaultPassword
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        customer = try container.decode(String.self, forKey: .customer)
        businessUnit = try container.decode(String.self, forKey: .businessUnit)
        usesMfa = try container.decodeIfPresent(Bool.self, forKey: .mfa) ?? false
        defaultUsername = try container.decodeIfPresent(String.self, forKey: .defaultUsername)
        defaultPassword = try container.decodeIfPresent(String.self, forKey: .defaultPassword)
    }
    
    internal enum CodingKeys: String, CodingKey {
        case name
        case customer
        case businessUnit
        case mfa
        case defaultUsername
        case defaultPassword
    }
}

extension CustomerConfig {
    var pickerModelTitle: String {
        return name
    }
}
