//
//  EmbeddedCarouselLayoutDelegate.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import CoreGraphics

protocol EmbeddedCarouselLayoutDelegate: class {
    func estimatedCellSize(for bounds: CGRect) -> CGSize
}
