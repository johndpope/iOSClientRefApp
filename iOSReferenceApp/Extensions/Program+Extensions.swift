//
//  Program+Extensions.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2018-01-11.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import Exposure

extension Program {
    static var exposureDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }
    
    var startDate: Date? {
        return exposureFormattedDate(string: startTime)
    }
    
    var endDate: Date? {
        return exposureFormattedDate(string: endTime)
    }
    
    func exposureFormattedDate(string: String?) -> Date? {
        guard let dateString = string else { return nil }
        
        let formatter = Program.exposureDateFormatter
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter.date(from: dateString)
    }
}
