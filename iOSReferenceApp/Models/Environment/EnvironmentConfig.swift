//
//  EnvironmentConfig.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-03-27.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import SwiftyJSON
import Exposure

struct EnvironmentConfig {
    let name: String
    let url: String
    let customers: [CustomerConfig]
    
    init(name: String, url: String, customers: [CustomerConfig]) {
        self.name = name
        self.url = url
        self.customers = customers
    }
}

extension EnvironmentConfig {
    var pickerModelTitle: String {
        return name
    }
    
    init?(json: JSON) {
        guard let name = json["name"].string,
            let url = json["exposureUrl"].string else { return nil }
        
        self.name = name
        self.url = url
        if let payload = json["customers"].array {
            customers = payload.flatMap{ CustomerConfig(json: $0) }
        }
        else {
            customers = []
        }
    }
}

extension EnvironmentConfig {
    static func preconfigured(file: String) -> [EnvironmentConfig] {
        guard let path = Bundle.main.path(forResource: file, ofType: "json") else { return [] }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            let json = JSON(data: data)
            
            guard let payload = json.array else { return [] }
            return payload.flatMap{ EnvironmentConfig(json: $0) }
        }
        catch {
            return []
        }
    }
    
    static func preconfigured(files: [String]) -> [EnvironmentConfig] {
        return files.flatMap{ preconfigured(file: $0) }
    }
}
