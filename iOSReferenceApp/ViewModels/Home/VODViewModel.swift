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
    let environment: Environment
    let carouselId: String
    let sessionToken: SessionToken
    
    fileprivate(set) var carousels: [CarouselItemViewModel] = []
    
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
}

// MARK: PreviewAssetCellConfig
extension VODViewModel: PreviewAssetCellConfig {
    func rowHeight(index: Int) -> CGFloat {
        let carousel = carousels[index]
        if let items = carousel.item.items?.items, items.isEmpty { return 0 }
        return (carousel.preferredCellSize.height + 2*carousel.previewCellPadding)
    }

    func getSectionTitle(atIndex section: Int) -> String {
        return carousels[section].item.titles?.first?.title ?? "No title"
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

    var preferredCellsPerRow: CGFloat {
        return 3
    }

    var previewCellPadding: CGFloat {
        return 5
    }
}
