//
//  EditorialCell.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

protocol EditorialCell {
    associatedtype Editorial
    func configure(with editorial: Editorial?, for index: Int, size: CGSize)
    var selectedAsset: (Asset) -> Void { get set }
}
