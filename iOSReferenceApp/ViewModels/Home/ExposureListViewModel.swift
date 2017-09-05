//
//  ExposureListViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-06-01.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class ExposureListViewModel: AuthorizedEnvironment {
    // MARK: Basics
    let credentials: Credentials
    
    fileprivate(set) var categories: [CategoryViewModel]

    typealias AssetType = Asset.AssetType
    
    init(credentials: Credentials, environment: Environment) {
        self.credentials = credentials
        self.environment = environment
        
        self.categories = [
            .tvChannel,
            .movie
            ]
            .map{ CategoryViewModel(type: $0, environment: environment) }
    }
    
    convenience init(sessionToken: SessionToken, environment: Environment) {
        let cred = Credentials(sessionToken: sessionToken,
                               crmToken: nil,
                               accountId: nil,
                               expiration: nil,
                               accountStatus: nil)
        
        self.init(credentials: cred,
                  environment: environment)
    }
    
    func loadCategories(callback: @escaping (Int?, ExposureError?) -> Void) {
        (0..<categories.count).forEach{ index in
            let vm = categories[index]
            vm.fetchMetadata(batch: 1) { error in
                if let error = error {
                    callback(nil,error)
                }
                else {
                    callback(index,nil)
                }
            }
        }
    }
    
    // MARK: AuthorizedEnvironment
    let environment: Environment
    var sessionToken: SessionToken {
        return credentials.sessionToken
    }
}

// MARK: PreviewAssetCellConfig
extension ExposureListViewModel: PreviewAssetCellConfig {
    func rowHeight(index: Int) -> CGFloat {
        let category = categories[index]
        guard category.content.count > 0 else { return 0 }
        return (category.preferredCellSize.height + 2*category.previewCellPadding)
    }
}


extension ExposureListViewModel {
    func category(for type: AssetType) -> CategoryViewModel {
        return categories.filter{ $0.type == type }.first!
    }
    
    func assetType(index: Int) -> AssetType {
        return categories[index].type
    }
}
