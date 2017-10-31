//
//  CarouselEditorial.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

protocol CarouselEditorial: EmbeddedCarouselLayoutDelegate {
    var layout: CollectionViewLayout { get }
    func editorial<T: ContentEditorial>(for index: Int) -> T?
    var content: [ContentEditorial] { get }
    func append(content: [ContentEditorial])
    
    var count: Int { get }
    
    // MARK: Editorial Layout
    var usesCarouselSpecificEditorial: Bool { get }
    
    // Carousel Editorial
//    var title: String? { get }
//    var text: String? { get }
//    var sideInset: CGFloat { get }
}
