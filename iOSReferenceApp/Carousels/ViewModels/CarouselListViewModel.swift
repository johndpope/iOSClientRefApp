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
    func loadFakeCarousel(callback: @escaping (Int, ExposureError?) -> Void) {
        let list: [(CarouselViewModel, Asset.AssetType)] = [
            (CarouselViewModel(editorial: HeroPromotionEditorial()), .movie),
            (CarouselViewModel(editorial: PortraitTrioPromotionEditorial()), .clip),
            (CarouselViewModel(editorial: BasicPromotionEditorial(title: "Movies")), .movie),
            (CarouselViewModel(editorial: BasicPromotionEditorial(title: "Movies", aspectRatio: BasicPromotionEditorial.AspectRatio(width: 3, height: 2))), .movie)
        ]
        content = list.map{ $0.0 }
        
        (0..<list.count).forEach{ index in
            let conf = list[index]
            let vm = conf.0
            vm.fakeCarouselMetadataFetch(environment: environment,
                                         sessionToken: sessionToken,
                                         type: conf.1) { error in
                                            callback(index, error)
            }
        }
    }
    
}

extension CarouselListViewModel: AuthorizedEnvironment {
    
}
