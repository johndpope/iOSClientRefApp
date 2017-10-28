//
//  CarouselViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-22.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure
import Kingfisher
import UIKit


class CarouselViewModel {
    fileprivate(set) var editorial: CarouselEditorial
    
    init(editorial: CarouselEditorial) {
        self.editorial = editorial
    }
}
