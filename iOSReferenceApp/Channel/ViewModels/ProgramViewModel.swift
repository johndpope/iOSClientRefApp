//
//  ProgramViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-07-10.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure
//
//class ProgramViewModel {
//    fileprivate(set) var program: Program
//
//    typealias ExposureImage = Image
//
//    init(program: Program) {
//        self.program = program
//    }
//}
//
//extension ProgramViewModel: LocalizedEntity {
//    var locales: [String] {
//        return program.asset?.localized?.flatMap{ $0.locale } ?? []
//    }
//
//    func localizedData(locale: String) -> LocalizedData? {
//        return program.asset?.localized?.filter{ $0.locale == locale }.first
//    }
//
//    func localizations() -> [LocalizedData] {
//        return program.asset?.localized ?? []
//    }
//
//    func anyTitle(locale: String) -> String {
//        if let title = title(locale: locale), title != "" { return title }
//        else if let originalTitle = program.asset?.originalTitle, originalTitle != "" { return originalTitle }
//        else if let assetId = program.asset?.assetId { return assetId }
//        return "NO TITIE"
//    }
//
//    func anyDescription(locale: String) -> String {
//        if let description = localizedData(locale: locale)?.allDescriptions().last {
//            return description
//        }
//        return localizations().flatMap{ $0.allDescriptions() }.last ?? ""
//    }
//}

