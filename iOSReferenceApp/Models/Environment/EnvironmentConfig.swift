//
//  EnvironmentConfig.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-03-27.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

struct EnvironmentConfig: Decodable {
    let name: String
    let url: String
    let customers: [CustomerConfig]
    
    init(name: String, url: String, customers: [CustomerConfig]) {
        self.name = name
        self.url = url
        self.customers = customers
    }
    
    
    internal enum CodingKeys: String, CodingKey {
        case name
        case url = "exposureUrl"
        case customers
    }
}

extension EnvironmentConfig {
    var pickerModelTitle: String {
        return name
    }
}

extension EnvironmentConfig {
    static func preconfigured(file: String) -> [EnvironmentConfig] {
        guard let path = Bundle.main.path(forResource: file, ofType: "json") else { return [] }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            
            return try JSONDecoder().decode([EnvironmentConfig].self, from: data)
        }
        catch {
            return []
        }
    }
    
    static func preconfigured(files: [String]) -> [EnvironmentConfig] {
        return files.flatMap{ preconfigured(file: $0) }
    }
}
