//
//  SingleCarouselViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-03.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Kingfisher
import Exposure

class SingleCarouselViewModel: AuthorizedEnvironment {
    func authorize(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
    var environment: Environment
    var sessionToken: SessionToken
    
    init(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
    var aspectRatio: CGFloat = 2/3
    var preferredCellSpacing: CGFloat = 0
    var preferredCellsPerRow: Int = 1
    var labelHeight: CGFloat = 20
    var edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    fileprivate(set) var content: [AssetViewModel] = []
    
}

extension SingleCarouselViewModel {
    func preferredCellSize(forWidth width: CGFloat) -> CGSize {
        let thumbSize = preferredThumbnailSize(forWidth: width)
        return CGSize(width: thumbSize.width, height: thumbSize.height + labelHeight)
    }
    
    func preferredThumbnailSize(forWidth width: CGFloat) -> CGSize {
        let cellsPerRow = CGFloat(preferredCellsPerRow)
        let cellWidth = (width - edgeInsets.left - edgeInsets.right)/cellsPerRow - (cellsPerRow - 1)*preferredCellSpacing
        let cellHeight =  cellWidth * aspectRatio
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension SingleCarouselViewModel {
    func loadCarousel(for carouselId: String, callback: @escaping (ExposureError?) -> Void) {
//        FetchCarouselList(groupId: groupId,
//                          environment: environment)
//            .request()
//            .validate()
//            .response { [weak self] (response: ExposureResponse<CarouselList>) in
//                guard let weakSelf = self else { return }
//                guard let items = response.value?.items else { return }
//
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
//
//                callback(response.error)
//        }
    }
}

extension SingleCarouselViewModel {
    func loadFakeMovieCarousel(callback: @escaping (ExposureError?) -> Void) {
        let fetch = FetchAsset(environment: environment)
            .list()
            .includeUserData(for: sessionToken)
            .elasticSearch(query: "(medias.drm:FAIRPLAY OR medias.drm:UNENCRYPTED) AND medias.format:HLS")
            .elasticSearch(publicationQuery: "publications.products:EnigmaFVOD_enigma")
            .sort(on: "originalTitle")
            .filter(onlyPublished: true)
            .filter(on: .movie)
        
        createFakeCarousel(for: fetch, callback: callback)
    }
    
    func loadFakeDocumentariesCarousel(callback: @escaping (ExposureError?) -> Void) {
        //        FetchAsset(environment: environment)
        //            .list()
        //            .includeUserData(for: sessionToken)
        //            .elasticSearch(query: "(medias.drm:FAIRPLAY OR medias.drm:UNENCRYPTED) AND medias.format:HLS")
    }
    
    func loadFakeKidsCarousel(callback: @escaping (ExposureError?) -> Void) {
        let fetch = FetchAsset(environment: environment)
            .list()
            .includeUserData(for: sessionToken)
            .elasticSearch(query: "(medias.drm:FAIRPLAY OR medias.drm:UNENCRYPTED) AND medias.format:HLS")
            .elasticSearch(publicationQuery: "publications.products:kidsContent_enigma")
            .sort(on: "originalTitle")
            .filter(onlyPublished: true)
            .filter(on: .movie)
        
        createFakeCarousel(for: fetch, callback: callback)
    }
    
    func loadFakeClipsCarousel(callback: @escaping (ExposureError?) -> Void) {
        let fetch = FetchAsset(environment: environment)
            .list()
            .includeUserData(for: sessionToken)
            .elasticSearch(query: "(medias.drm:FAIRPLAY OR medias.drm:UNENCRYPTED) AND medias.format:HLS")
            .sort(on: "originalTitle")
            .filter(onlyPublished: true)
            .filter(on: .clip)
        
        createFakeCarousel(for: fetch, callback: callback)
    }
    
    private func createFakeCarousel(for fetch: FetchAssetList, callback: @escaping (ExposureError?) -> Void) {
        
        let itemsPerCarousel = 10
        
        fetch
            .show(page: 1, spanning: itemsPerCarousel)
            .request()
            .response{ [weak self] (exposure: ExposureResponse<AssetList>) in
                if let success = exposure.value {
                    guard let weakSelf = self else { return }
                    guard let assets = success.items else { return }
                    
                    weakSelf.content = assets.flatMap{ AssetViewModel(asset: $0) }
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
}

extension SingleCarouselViewModel {
    
    private func thumbnailImageProcessor(for width: CGFloat) -> ImageProcessor {
        let thumbSize = preferredThumbnailSize(forWidth: width)
        let resizeProcessor = CrispResizingImageProcessor(referenceSize: thumbSize, mode: ContentMode.aspectFill)
        let croppingProcessor = CroppingImageProcessor(size: thumbSize)
        return (resizeProcessor>>croppingProcessor)
    }
    
    func thumbnailImageOptions(for width: CGFloat) -> KingfisherOptionsInfo {
        return [
            .backgroundDecode,
            .cacheMemoryOnly,
            .processor(thumbnailImageProcessor(for: width))
        ]
    }
    
    func imageUrl(for indexPath: IndexPath) -> URL? {
        return content[indexPath.row]
            .images(locale: "en")
            .prefere(orientation: .portrait)
            .validImageUrls()
            .first
    }
}
