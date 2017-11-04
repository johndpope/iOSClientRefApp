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
    
    fileprivate(set) var carousels: [AssetListType] = []
    
    init(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }

    func loadCarousel(group: String, callback: @escaping (ExposureError?) -> Void) {
        if group == "fakeCarousels" {
            loadFakeCarousel(callback: callback)
        }
        else {
            loadCarousels(for: group, callback: callback)
        }
    }
    
    fileprivate func loadCarousels(for groupId: String, callback: @escaping (ExposureError?) -> Void) {
        FetchCarousel(environment: environment)
            .group(id: groupId)
            .request()
            .validate()
            .response { (response: ExposureResponse<CarouselList>) in
                guard let items = response.value?.items else { return }
                self.carousels = items.map { BasicCarouselViewModel(item: $0) }
                callback(response.error)
        }
    }
    
    fileprivate func loadFakeCarousel(callback: @escaping (ExposureError?) -> Void) {
        let fakeCarousels = [
            CategoryViewModel(type: .movie, environment: environment, sessionToken: sessionToken),
            CategoryViewModel(type: .clip, environment: environment, sessionToken: sessionToken)
        ]
        
        carousels = fakeCarousels
        
        fakeCarousels
            .forEach{
                $0.fetchMetadata(batch: 1) { _, error in
                    callback(error)
                }
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

struct BasicCarouselViewModel: AssetListType {
    var content: [AssetViewModel] {
        get {
            return item.items?.items?.flatMap { AssetViewModel(asset: $0) } ?? []
        }
    }

    var item: CarouselItem

    init(item: CarouselItem) {
        self.item = item
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
    
    func anyTitle() -> String? {
        return item.titles?.first?.title?.uppercased()
    }
}
