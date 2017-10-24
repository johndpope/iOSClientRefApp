//
//  CarouselItemViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

protocol CarouselItemViewModelType: Hashable {
    associatedtype AssetData
    associatedtype EditorialData
    
    var data: AssetData { get }
    var editorial: EditorialData { get }
}

class CarouselItemViewModel<Editorial>: CarouselItemViewModelType {
    fileprivate(set) var data: Asset
    fileprivate(set) var editorial: Editorial?
    
    init(data: Asset, editorial: Editorial?) {
        self.data = data
        self.editorial = editorial
    }
}

extension CarouselItemViewModel: Hashable  {
    var hashValue: Int {
        return data.assetId?.hashValue ?? -1
    }
}

extension CarouselItemViewModel: Equatable {
    public static func == (lhs: CarouselItemViewModel, rhs: CarouselItemViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}


extension CarouselItemViewModel: LocalizedAssetEntity {
    var asset: Asset {
        return data
    }
}

extension CarouselItemViewModel {
    var publicationDate: String? {
        return data.publications?.first?.publicationDate
    }
    
    var availableFromDate: String? {
        return data.publications?.first?.fromDate
    }
    
    var availableToDate: String? {
        return data.publications?.first?.toDate
    }
}
