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
        if let editorial = editorial as? HeroPromotionEditorial {
            guard editorial.usesItemSpecificEditorials else {
                return assetList.map{ HeroItemPromotionEditorial(data: $0) }
            }
            
            return assetList.map{
                HeroItemPromotionEditorial(title: $0.anyTitle(locale: "en"), text: descriptionOrFake(for: $0), data: $0) }
        }
        else if let editorial = editorial as? PortraitTrioPromotionEditorial {
            let cellData = assetList
                .chuncked(by: 3)
                .flatMap{ list -> (PortraitTrioItemPromotionEditorial.Data)? in
                    guard let first = list.first else { return nil }
                    return PortraitTrioItemPromotionEditorial.Data(first: first,
                                                                   second: (list.count > 1 ? list[1] : nil),
                                                                   third: (list.count > 2 ? list[2] : nil))
            }
            guard editorial.usesItemSpecificEditorials else {
                return cellData.map{ PortraitTrioItemPromotionEditorial(data: $0) }
            }
            return cellData.map{ PortraitTrioItemPromotionEditorial(title: $0.first.anyTitle(locale: "en"), text: descriptionOrFake(for: $0.first), data: $0) }
        }
        else if let editorial = editorial as? BasicPromotionEditorial {
            guard editorial.usesItemSpecificEditorials else {
                return assetList.map{ BasicItemPromotionEditorial(data: $0) }
            }
            
            return assetList.map{ BasicItemPromotionEditorial(data: $0, title: $0.anyTitle(locale: "en")) }
        }
        else if let editorial = editorial as? BannerPromotionEditorial {
            guard editorial.usesItemSpecificEditorials else {
                return assetList.map{ BannerItemPromotionEditorial(data: $0) }
            }
            
            return assetList.map{ BannerItemPromotionEditorial(data: $0, title: $0.anyTitle(locale: "en")) }
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
    
    func fakeCarouselMetadataFetch(environment: Environment, sessionToken: SessionToken, type: Asset.AssetType, callback: @escaping (ExposureError?) -> Void) {
        FetchAsset(environment: environment)
            .list()
            .includeUserData(for: sessionToken)
            //            .elasticSearch(query: "medias.drm:UNENCRYPTED AND medias.format:HLS")
            .elasticSearch(query: "(medias.drm:FAIRPLAY OR medias.drm:UNENCRYPTED) AND medias.format:HLS")
            .show(page: 1, spanning: 50)
            .filter(on: type)
            .filter(onlyPublished: true)
            .sort(on: ["-assetId"])
            .request()
            .response{ [weak self] (exposure: ExposureResponse<AssetList>) in
                if let success = exposure.value {
                    guard let weakSelf = self else { return }
                    guard let assets = success.items else { return }
                    let editorials = weakSelf.fakeEditorials(for: assets)
                    weakSelf.editorial.append(content: editorials)
                    callback(nil)
                }
                
                if let error = exposure.error {
                    callback(error)
                }
        }
    }
}
