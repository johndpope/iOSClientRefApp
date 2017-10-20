//
//  LiveListViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-06-01.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class LiveListViewModel: AuthorizedEnvironment {
    // MARK: AuthorizedEnvironment
    var environment: Environment
    var sessionToken: SessionToken
    func authorize(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
    fileprivate(set) var categories: [CategoryViewModel] = []
    
    typealias AssetType = Asset.AssetType
    init(sessionToken: SessionToken, environment: Environment) {
        self.sessionToken = sessionToken
        self.environment = environment
        
        self.categories = [
            .tvChannel,
            .liveEvent,
            ]
            .map{ CategoryViewModel(type: $0, environment: environment, sessionToken: sessionToken) }
    }
    
    func loadCategories(callback: @escaping (Int?, ExposureError?) -> Void) {
        (0..<categories.count).forEach{ index in
            let vm = categories[index]
            vm.fetchMetadata(batch: 1) { (batch, error) in
                if let error = error {
                    callback(nil,error)
                }
                else {
                    callback(index,nil)
                }
            }
        }
    }
}

// MARK: PreviewAssetCellConfig
extension LiveListViewModel: PreviewAssetCellConfig {
    func rowHeight(index: Int) -> CGFloat {
        let category = categories[index]
        guard category.content.count > 0 else { return 0 }
        return (category.preferredCellSize.height + 2*category.previewCellPadding)
    }
}


extension LiveListViewModel {
    func category(for type: AssetType) -> CategoryViewModel {
        return categories.filter{ $0.type == type }.first!
    }
    
    func assetType(index: Int) -> AssetType {
        return categories[index].type
    }
}
