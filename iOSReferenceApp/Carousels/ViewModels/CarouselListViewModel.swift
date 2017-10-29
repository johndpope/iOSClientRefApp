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
//        content = [
//            CarouselViewModel(editorial: HeroPromotionEditorial()),
//            CarouselViewModel(editorial: PortraitTrioPromotionEditorial()),
//            CarouselViewModel(editorial: BasicPromotionEditorial(title: "Landscape Title")),
//            CarouselViewModel(editorial: HeroPromotionEditorial())
//        ]
        let list: [(CarouselViewModel, Asset.AssetType)] = [
            (CarouselViewModel(editorial: HeroPromotionEditorial()), .movie),
            (CarouselViewModel(editorial: BasicPromotionEditorial(title: "Portrait", aspectRatio: BasicPromotionEditorial.AspectRatio(width: 2, height: 3))), .clip),
            (CarouselViewModel(editorial: PortraitTrioPromotionEditorial()), .clip),
            (CarouselViewModel(editorial: BasicPromotionEditorial(title: "Landscape Title")), .movie),
            (CarouselViewModel(editorial: HeroPromotionEditorial()), .clip),
        ]
        list.forEach{ (vm, type) in
            vm.fakeCarouselMetadataFetch(environment: environment,
                                         sessionToken: sessionToken,
                                         type: type) { [weak self] error in
                                            guard let weakSelf = self else { return }
                                            let index = weakSelf.content.count
                                            vm.editorial.layout.use(pagination: true)
                                            print("LOADED INDEX:",index)
                                            weakSelf.content.append(vm)
                                            callback(index, error)
            }
        }
    }
    
}

extension CarouselListViewModel: AuthorizedEnvironment {
    
}
