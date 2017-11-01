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
    struct Shared {
        let editorialHeight: CGFloat = 38
        let slimEditorialHeight: CGFloat = 28
        let footerHeight: CGFloat = 40
        let edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 30, bottom: 0, right: 30)
        let contentSpacing: CGFloat = 15
        let thumbnailRoundness: CGFloat? = nil
    }
    
    // MARK: Basics
    var environment: Environment
    var sessionToken: SessionToken
    func authorize(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
    fileprivate(set) var bannerViewModel: CarouselViewModel?
    fileprivate(set) var content: [CarouselViewModel] = []
    
    init(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
    func loadCarousels(for groupId: String, callback: @escaping (ExposureError?) -> Void) {
        FetchCarouselList(groupId: groupId,
                          environment: environment)
            .request()
            .validate()
            .response { [weak self] (response: ExposureResponse<CarouselList>) in
                guard let weakSelf = self else { return }
                guard let items = response.value?.items else { return }
                
                if let banner = items.first {
                    let editorial = BannerPromotionEditorial()
                    editorial.bannerLayout.use(pagination: true)
                    let bannerCarousel = CarouselViewModel(editorial: editorial)
                    
                    if let list = banner.items?.items {
                        let assets = bannerCarousel.fakeEditorials(for: list)
                        editorial.append(content: assets)
                    }
                    weakSelf.bannerViewModel = bannerCarousel
                    if items.count > 1 {
                        weakSelf.content = (1..<items.count).map { index in
                            let carouselItem = items[index]
                            let title = carouselItem.titles?.anyTitle(locale: "en") ?? "Some Title"
                            
                            let editorial = BasicPromotionEditorial(title: title, aspectRatio: BasicPromotionEditorial.AspectRatio(width: 3, height: 2))
                            editorial.basicLayout.use(pagination: true)
                            let carousel = CarouselViewModel(editorial: editorial)
                            
                            let content = carouselItem
                                .items?
                                .items?
                                .map{ return BasicItemPromotionEditorial(data: $0, title: $0.anyTitle(locale: "en")) } ?? []
                            editorial.append(content: content)
                            return carousel
                        }
                    }
                }
                
                
                callback(response.error)
        }
    }
}

extension CarouselListViewModel {
    func loadFakeCarousel(callback: @escaping (Int, ExposureError?) -> Void) {
        let bannerEditorial = BannerPromotionEditorial()
        bannerViewModel = CarouselViewModel(editorial: bannerEditorial)
        bannerViewModel?.fakeCarouselMetadataFetch(environment: environment,
                                                   sessionToken: sessionToken,
                                                   type: .movie) { [weak self] error in
                                                    guard let weakSelf = self else { return }
                                                    
                                                    bannerEditorial.layout.use(pagination: true)
                                                    print("LOADED BANNER")
                                                    weakSelf.fakeCarousel(callback: callback)
        }
    }
    
    private func fakeCarousel(callback: @escaping (Int, ExposureError?) -> Void) {
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
                                            weakSelf.content.append(vm)
                                            callback(index, error)
            }
        }
    }
    
}

extension CarouselListViewModel: AuthorizedEnvironment {
    
}
