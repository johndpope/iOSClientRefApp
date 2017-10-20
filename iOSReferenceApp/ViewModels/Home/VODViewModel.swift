//
//  VODViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-05-30.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class VODViewModel: AuthorizedEnvironment {
    // MARK: Basics
    var environment: Environment
    var sessionToken: SessionToken
    func authorize(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
    let carouselId: String
    
    fileprivate(set) var carousels: [AssetListType] = []
    
    init(carouselId: String, environment: Environment, sessionToken: SessionToken) {
        self.carouselId = carouselId
        self.environment = environment
        self.sessionToken = sessionToken
    }

    func loadCarousels(callback: @escaping (ExposureError?) -> Void) {
        FetchCarouselList(groupId: carouselId,
                          environment: environment)
            .request()
            .validate()
            .response { (response: ExposureResponse<CarouselList>) in
                guard let items = response.value?.items else { return }
                self.carousels = items.map { CarouselItemViewModel(item: $0) }
                callback(response.error)
        }
    }
    
    func loadFakeCarousel(callback: @escaping (ExposureError?) -> Void) {
        let fakeCarousel = CategoryViewModel(type: .movie, environment: environment, sessionToken: sessionToken)
        carousels = [fakeCarousel]
        
        fakeCarousel.fetchMetadata(batch: 1) { _, error in
            callback(error)
        }
    }
}

// MARK: PreviewAssetCellConfig
extension VODViewModel: PreviewAssetCellConfig {
    func rowHeight(index: Int) -> CGFloat {
        let carousel = carousels[index]
        if carousel.content.isEmpty { return 0 }
        return (carousel.preferredCellSize.height + 2*5)
    }

    func getSectionTitle(atIndex section: Int) -> String {
        return carousels[section].anyTitle() ?? "No title"
    }
}

// MARK: - Fetch Metadata
extension VODViewModel {
    // MARK: Exposure Assets
}

struct CarouselItemViewModel: AssetListType {
    var content: [AssetViewModel] {
        get {
            return item.items?.items?.flatMap { AssetViewModel(asset: $0) } ?? []
        }
    }

    var item: CarouselItem

    init(item: CarouselItem) {
        self.item = item
    }

    var preferredCellSize: CGSize {
        return CGSize(width: 108, height: 186)
    }
    
    var preferredThumbnailSize: CGSize {
        return CGSize(width: 108, height: 162)
    }
    
    func preferredCellSize(forWidth width: CGFloat) -> CGSize {
        return preferredCellSize
    }
    
    func preferredThumbnailSize(forWidth width: CGFloat) -> CGSize {
        return preferredThumbnailSize
    }

    var preferredCellsPerRow: CGFloat {
        return 3
    }

    var previewCellPadding: CGFloat {
        return 5
    }
    
    func anyTitle() -> String? {
        return item.titles?.first?.title?.uppercased()
    }
}
