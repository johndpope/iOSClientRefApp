//
//  CarouselListViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-22.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class CarouselListViewModel {
    // MARK: Basics
    var environment: Environment
    var sessionToken: SessionToken
    func authorize(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
    fileprivate(set) var content: [CarouselViewModel<HeroPromotionEditorial, HeroItemPromotionEditorial>] = []
    
    init(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
    func loadCarousel(group: String, callback: @escaping (ExposureError?) -> Void) {
        if group == "fakeCarousels" {
            loadFakeCarousel(callback: callback)
        }
        else {
            //            loadCarousels(for: group, callback: callback)
        }
    }
    
//    fileprivate func loadCarousels(for groupId: String, callback: @escaping (ExposureError?) -> Void) {
//        FetchCarouselList(groupId: groupId,
//                          environment: environment)
//            .request()
//            .validate()
//            .response { (response: ExposureResponse<CarouselList>) in
//                guard let items = response.value?.items else { return }
//                self.carousels = items.map { BasicCarouselViewModel(item: $0) }
//                callback(response.error)
//        }
//    }
    
}

extension CarouselListViewModel {
    fileprivate func loadFakeCarousel(callback: @escaping (ExposureError?) -> Void) {
        let list:[(CarouselViewModel<HeroPromotionEditorial, HeroItemPromotionEditorial>, Asset.AssetType)] = [
            (CarouselViewModel(carousel: HeroPromotionEditorial(), data: []), .movie),
            (CarouselViewModel(carousel: HeroPromotionEditorial(), data: []), .clip)
        ]
        
        content = list.map{ $0.0 }
        
        list.forEach{ vm, type in
            fetchMetadata(type: type) { [weak self] list, error in
                guard let weakSelf = self else { return }
                if let items = list?.items {
                    let data =  items.map{ asset -> CarouselItemViewModel<HeroItemPromotionEditorial> in
                        let editorial = vm.editorial.usesItemSpecificEditorials ? weakSelf.fakeEditorial(for: asset) : nil
                        return CarouselItemViewModel(data: asset, editorial: editorial)
                    }
                    vm.content = data
                }
                callback(error)
            }
        }
    }
    
    private func fakeEditorial(for asset: Asset) -> HeroItemPromotionEditorial? {
        return HeroItemPromotionEditorial(title: asset.anyTitle(locale: "en"), text: asset.anyDescription(locale: "en"))
    }
    
    fileprivate func fetchMetadata(type: Asset.AssetType, callback: @escaping (AssetList?, ExposureError?) -> Void) {
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
            .response{ (exposure: ExposureResponse<AssetList>) in
                if let success = exposure.value {
                    callback(success, nil)
                }
                
                if let error = exposure.error {
                    callback(nil, error)
                }
        }
    }
}

extension CarouselListViewModel: AuthorizedEnvironment {
    
}
