//
//  Sequence+Extensions.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-05-31.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

extension Sequence {
    func categorise<U: Hashable>(key: (Iterator.Element) -> U) -> [U: [Iterator.Element]] {
        var dict: [U: [Iterator.Element]] = [:]
        self.forEach{
            let k = key($0)
            dict[k] = (dict[k] ?? []) + [$0]
        }
        return dict
    }
}
