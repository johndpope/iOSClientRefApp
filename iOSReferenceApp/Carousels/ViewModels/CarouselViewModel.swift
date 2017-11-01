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

// MARK: - Fake Carousels
extension CarouselViewModel {
    func fakeEditorials(for assetList: [Asset]) -> [ContentEditorial] {
        if editorial is HeroPromotionEditorial {
            return assetList.map{
                HeroItemPromotionEditorial(title: $0.anyTitle(locale: "en"), text: descriptionOrFake(for: $0), data: $0) }
        }
        else if editorial is PortraitTrioPromotionEditorial {
            let cellData = assetList
                .chuncked(by: 3)
                .flatMap{ list -> (PortraitTrioItemPromotionEditorial.Data)? in
                    guard let first = list.first else { return nil }
                    return PortraitTrioItemPromotionEditorial.Data(first: first,
                                                                   second: (list.count > 1 ? list[1] : nil),
                                                                   third: (list.count > 2 ? list[2] : nil))
            }
            
            return cellData.map{ PortraitTrioItemPromotionEditorial(title: $0.first.anyTitle(locale: "en"), text: descriptionOrFake(for: $0.first), data: $0) }
        }
        else if editorial is BasicPromotionEditorial {
            return assetList.map{ BasicItemPromotionEditorial(data: $0, title: $0.anyTitle(locale: "en")) }
        }
        else if editorial is BannerPromotionEditorial {
            return assetList.map{ BannerItemPromotionEditorial(data: $0, title: $0.anyTitle(locale: "en"), text: $0.anyDescription(locale: "en")) }
        }
        return []
    }
    
    private func descriptionOrFake(for asset: Asset) -> String {
        let desc = asset.anyDescription(locale: "en")
        guard desc != "" else {
            return "Some amazing promotional text here!"
        }
        return desc
    }
}
