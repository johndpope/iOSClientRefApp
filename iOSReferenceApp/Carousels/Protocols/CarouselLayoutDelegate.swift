//
//  CarouselLayoutDelegate.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import CoreGraphics

protocol CarouselLayoutDelegate {
    var carouselSpecificEditorialHeight: CGFloat? { get }
    var carouselFooterHeight: CGFloat { get }
    var carouselContentSideInset: CGFloat { get }
    var carouselContentTopInset: CGFloat { get }
    var itemSpecificEditorialHeight: CGFloat? { get }
}
