//
//  Date+Extensions.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-07-10.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

extension Date {
    func subtract(days: UInt) -> Date? {
        var components = DateComponents()
        components.setValue(-Int(days), for: Calendar.Component.day)
        
        return Calendar.current.date(byAdding: components, to: self)
    }
    
    func add(days: UInt) -> Date? {
        var components = DateComponents()
        components.setValue(Int(days), for: Calendar.Component.day)
        
        return Calendar.current.date(byAdding: components, to: self)
    }
    
    func dateString(format: String) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = format
        return timeFormatter.string(from: self)
    }
}
