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
    
    func reset() {
        bannerViewModel = nil
        content = []
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
    func navigationTitle(with contentType: CarouselViewController.ContentType) -> String {
        switch contentType {
        case .fakeCarousels: return "Home"
        case .carouselGroup(groupId: _): return "Home"
        case .movies: return "Movies"
        case .documentaries: return "Documentaries"
        case .kids: return "Kids"
        case .clips: return "Clips"
        }
    }
}

extension CarouselListViewModel {
    func loadFakeMovieCarousels(callback: @escaping (ExposureError?) -> Void) {
        let fetch = FetchAsset(environment: environment)
            .list()
            .includeUserData(for: sessionToken)
            .elasticSearch(query: "(medias.drm:FAIRPLAY OR medias.drm:UNENCRYPTED) AND medias.format:HLS")
            .elasticSearch(publicationQuery: "publications.products:EnigmaFVOD_enigma")
            .sort(on: "originalTitle")
            .filter(onlyPublished: true)
            .filter(on: .movie)
        
        createFakeCarousels(for: fetch, callback: callback)
    }
    
    func loadFakeDocumentariesCarousels(callback: @escaping (ExposureError?) -> Void) {
//        FetchAsset(environment: environment)
//            .list()
//            .includeUserData(for: sessionToken)
//            .elasticSearch(query: "(medias.drm:FAIRPLAY OR medias.drm:UNENCRYPTED) AND medias.format:HLS")
    }
    
    func loadFakeKidsCarousels(callback: @escaping (ExposureError?) -> Void) {
        let fetch = FetchAsset(environment: environment)
            .list()
            .includeUserData(for: sessionToken)
            .elasticSearch(query: "(medias.drm:FAIRPLAY OR medias.drm:UNENCRYPTED) AND medias.format:HLS")
            .elasticSearch(publicationQuery: "publications.products:kidsContent_enigma")
            .sort(on: "originalTitle")
            .filter(onlyPublished: true)
            .filter(on: .movie)
        
        createFakeCarousels(for: fetch, callback: callback)
    }
    
    func loadFakeClipsCarousels(callback: @escaping (ExposureError?) -> Void) {
        let fetch = FetchAsset(environment: environment)
            .list()
            .includeUserData(for: sessionToken)
            .elasticSearch(query: "(medias.drm:FAIRPLAY OR medias.drm:UNENCRYPTED) AND medias.format:HLS")
            .sort(on: "originalTitle")
            .filter(onlyPublished: true)
            .filter(on: .clip)
        
        createFakeCarousels(for: fetch, callback: callback)
    }
    
    private func createFakeCarousels(for fetch: FetchAssetList, callback: @escaping (ExposureError?) -> Void) {
        let bannerEditorial = BannerPromotionEditorial()
        bannerEditorial.layout.use(pagination: true)
        bannerViewModel = CarouselViewModel(editorial: bannerEditorial)
        
        let itemsPerCarousel = 10
        
        fetch
            .show(page: 1, spanning: 50)
            .request()
            .response{ [weak self] (exposure: ExposureResponse<AssetList>) in
                if let success = exposure.value {
                    guard let weakSelf = self else { return }
                    guard let assets = success.items else { return }
                    let chunks = assets.chuncked(by: itemsPerCarousel)
                    
                    if let bannerAssets = chunks.first, let editorials = weakSelf.bannerViewModel?.fakeEditorials(for: bannerAssets) {
                        weakSelf.bannerViewModel?.editorial.append(content: editorials)
                        
                        if chunks.count > 1 {
                            let carouselViewModels = (1..<chunks.count).map{ index -> CarouselViewModel in
                                let vm =  CarouselViewModel(editorial: BasicPromotionEditorial(title: weakSelf.fakeCarouselTitle(for: index), aspectRatio: BasicPromotionEditorial.AspectRatio(width: 3, height: 2)))
                                let editorials = vm.fakeEditorials(for: chunks[index])
                                vm.editorial.append(content: editorials)
                                return vm
                            }
                            
                            weakSelf.content = carouselViewModels
                        }
                    }
                    callback(nil)
                }
                
                if let error = exposure.error {
                    callback(error)
                }
        }
        
        
//        case 1:
//        loadAssetCarouselActivity("Documentaries", "/content/asset?fieldSet=ALL&publicationQuery=publications.products:EnigmaFVOD_enigma&includeUserData=true&pageNumber=1&sort=originalTitle&pageSize=100&onlyPublished=true&assetType=MOVIE");
//        break;
//        case 4:
//        loadAssetCarouselActivity("Recently Watched", "/userplayhistory/lastviewed?fieldSet=ALL");
//        break;
    }
    
    private func fakeCarouselTitle(for index: Int) -> String {
        switch index {
        case 0: return "Recent"
        case 1: return "Popular"
        case 2: return "Oldies"
        case 3: return "Related"
        default: return "More \(index)"
        }
    }
}

extension CarouselListViewModel: AuthorizedEnvironment {
    
}
