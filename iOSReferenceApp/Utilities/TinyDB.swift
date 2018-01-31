//
//  TinyDB.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2018-01-31.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation

class TinyDB {
    static func save(string: String, for key: String) {
        UserDefaults.standard.set(string, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func string(for key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    static func save(bool: Bool, for key: String) {
        UserDefaults.standard.set(bool, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    static func bool(for key: String) -> Bool? {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    static func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

