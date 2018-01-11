//
//  ProgramViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-07-10.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class ProgramViewModel {
    fileprivate(set) var program: Program
    
    typealias ExposureImage = Image
    
    init?(program: Program) {
        self.program = program
    }
}

extension ProgramViewModel: LocalizedEntity {
    var locales: [String] {
        return program.asset?.localized?.flatMap{ $0.locale } ?? []
    }
    
    func localizedData(locale: String) -> LocalizedData? {
        return program.asset?.localized?.filter{ $0.locale == locale }.first
    }
    
    func localizations() -> [LocalizedData] {
        return program.asset?.localized ?? []
    }
    
    func anyTitle(locale: String) -> String {
        if let title = title(locale: locale), title != "" { return title }
        else if let originalTitle = program.asset?.originalTitle, originalTitle != "" { return originalTitle }
        else if let assetId = program.asset?.assetId { return assetId }
        return "NO TITIE"
    }
    
    func anyDescription(locale: String) -> String {
        if let description = localizedData(locale: locale)?.allDescriptions().last {
            return description
        }
        return localizations().flatMap{ $0.allDescriptions() }.last ?? ""
    }
}

extension ProgramViewModel {
    var isUpcoming: Bool {
        guard let start = program.startDate else { return false }
        
        let current = Date()
        
        return start > current
    }
    
    var isLive: Bool {
        guard let start = program.startDate, let end = program.endDate else { return false }
        
        let current = Date()
        
        return start < current && current < end
    }
    
    func programLiveProgress() -> Float? {
        guard isLive else { return nil }
        
        guard let start = program.startDate, let end = program.endDate else { return nil }
        
        let current = Date()
        
        let startMillis = Float(start.millisecondsSince1970)
        let currentMillis = Float(current.millisecondsSince1970)
        let endMillis = Float(end.millisecondsSince1970)
        
        return (currentMillis - startMillis) / (endMillis - startMillis)
    }
    
    func programDurationString(locale: String) -> String? {
        let current = Date()
        
        guard let start = program.startDate, let end = program.endDate else { return nil }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let startTime = timeFormatter.string(from: start)
        let endTime = timeFormatter.string(from: end)
        
        // Start | End | Current
        //
        //   X   |  X  |    X    ->  Today
        //  X-1  |  X  |    X    ->  Yesterday
        //   X   | X+1 |    X    ->  Tomorrow
        //
        // Otherwise, just use date
        let startComponents = Calendar.current.dateComponents([.day,.month], from: start)
        let endComponents = Calendar.current.dateComponents([.day,.month], from: end)
        let currentComponents = Calendar.current.dateComponents([.day,.month], from: current)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        if startComponents.day! == endComponents.day! {
            if startComponents.day! == currentComponents.day! {
                return "Today " + startTime + " - " + endTime
            }
            else if endComponents.day! == (currentComponents.day! - 1) {
                return "Yesterday " + startTime + " - " + endTime
            }
            else if startComponents.day! == (currentComponents.day! - 1) {
                return "Tomorrow " + startTime + " - " + endTime
            }
            else {
                return dateFormatter.string(from: start) + " " + startTime + " - " + endTime
            }
        }
        else {
            dateFormatter.dateFormat = "MMM d HH:mm"
            return dateFormatter.string(from: start) + " - " + dateFormatter.string(from: end)
        }
    }
}
