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
    
    fileprivate(set) var content: [CarouselViewModel] = []
    
    init(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
    func loadCarousel(group: String, callback: @escaping (ExposureError?) -> Void) {
//        if group == "fakeCarousels" {
            loadFakeCarousel(callback: callback)
//        }
//        else {
//            loadCarousels(for: group, callback: callback)
//        }
    }
    
//    fileprivate func loadCarousels(for groupId: String, callback: @escaping (ExposureError?) -> Void) {
//        FetchCarouselList(groupId: groupId,
//                          environment: environment)
//            .request()
//            .validate()
//            .response { [weak self] (response: ExposureResponse<CarouselList>) in
//                guard let weakSelf = self else { return }
//                guard let items = response.value?.items else { return }
//
//                weakSelf.content = items.map {
//                    let carousel = CarouselViewModel(editorial: HeroPromotionEditorial())
//
//                    if carousel.editorial.usesItemSpecificEditorials {
//                        carousel.content = $0
//                            .items?
//                            .items?
//                            .map{ return CarouselItemViewModel(data: $0, editorial: weakSelf.fakeEditorial(for: $0)) } ?? []
//                    }
//                    return carousel
//                }
//                callback(response.error)
//        }
//    }
}

extension CarouselListViewModel {
    fileprivate func loadFakeCarousel(callback: @escaping (ExposureError?) -> Void) {
        let list: [(CarouselViewModel, Asset.AssetType)] = [
            (CarouselViewModel(editorial: HeroPromotionEditorial()), .movie),
            (CarouselViewModel(editorial: PortraitTrioPromotionEditorial()), .clip)
        ]
        
        content = list.map{ $0.0 }
        
        list.forEach{ vm, type in
            fetchMetadata(type: type) { [weak self] list, error in
                guard let weakSelf = self else { return }
                guard let assets = list?.items else { return }
                let editorials = weakSelf.fakeEditorials(using: vm.editorial, for: assets)
                vm.editorial.append(content: editorials)
                callback(error)
            }
        }
    }
    
    fileprivate func fakeEditorials(using: CarouselEditorial, for assetList: [Asset]) -> [ContentEditorial] {
        if let editorial = using as? HeroPromotionEditorial {
            guard editorial.usesItemSpecificEditorials else {
                return assetList.map{ HeroItemPromotionEditorial(data: $0) }
            }
            
            return assetList.map{
                HeroItemPromotionEditorial(title: $0.anyTitle(locale: "en"), text: descriptionOrFake(for: $0), data: $0) }
        }
        else if let editorial = using as? PortraitTrioPromotionEditorial {
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
        return []
    }
    
    func descriptionOrFake(for asset: Asset) -> String {
        let desc = asset.anyDescription(locale: "en")
        guard desc != "" else {
            return "Some amazing promotional text here!"
        }
        return desc
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

extension Sequence {
    func chuncked(by size:Int) -> [[Element]] {
        return self.reduce(into:[]) { memo, cur in
            if memo.count == 0 {
                return memo.append([cur])
            }
            if memo.last!.count < size {
                memo.append(memo.removeLast() + [cur])
            } else {
                memo.append([cur])
            }
        }
    }
}
extension CarouselListViewModel: AuthorizedEnvironment {
    
}
