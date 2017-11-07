//
//  EPGViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-06.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class ChannelListViewModel {
    let environment: Environment
    let sessionToken: SessionToken
    
    init(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
}

extension ChannelListViewModel {
    func loadCarousels(for groupId: String, callback: @escaping (ExposureError?) -> Void) {
        FetchCarousel(environment: environment)
            .group(id: groupId)
            .request()
            .validate()
            .response { [weak self] (response: ExposureResponse<CarouselList>) in
                guard let weakSelf = self else { return }
                guard let items = response.value?.items else { return }
                
                callback(items)
//                if let banner = items.first {
//                    let editorial = BannerPromotionEditorial()
//                    editorial.bannerLayout.use(pagination: true)
//                    let bannerCarousel = CarouselViewModel(editorial: editorial)
//
//                    if let list = banner.items?.items {
//                        let assets = bannerCarousel.fakeEditorials(for: list)
//                        editorial.append(content: assets)
//                    }
//                    weakSelf.bannerViewModel = bannerCarousel
//                    if items.count > 1 {
//                        weakSelf.content = (1..<items.count).map { index in
//                            let carouselItem = items[index]
//                            let title = carouselItem.titles?.anyTitle(locale: "en") ?? "Some Title"
//
//                            let editorial = BasicPromotionEditorial(title: title, aspectRatio: BasicPromotionEditorial.AspectRatio(width: 3, height: 2))
//                            //                            editorial.basicLayout.use(pagination: true)
//                            let carousel = CarouselViewModel(editorial: editorial)
//
//                            let content = carouselItem
//                                .items?
//                                .items?
//                                .map{ return BasicItemPromotionEditorial(data: $0, title: $0.anyTitle(locale: "en")) } ?? []
//                            editorial.append(content: content)
//                            return carousel
//                        }
//                    }
//                }
//
                
                callback(response.error)
        }
    }
}

extension ChannelListViewModel: AuthorizedEnvironment {
    
}
