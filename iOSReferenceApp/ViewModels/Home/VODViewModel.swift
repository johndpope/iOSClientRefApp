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
    let credentials: Credentials
    
    fileprivate(set) var categories: [CategoryViewModel] = []
    
    init(credentials: Credentials, environment: Environment) {
        self.credentials = credentials
        self.environment = environment

        self.categories = [
            .movie,
            .clip,
            .episode,
            .ad
            ].map { CategoryViewModel(type: $0, environment: environment) }
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
        for (index, category) in categories.enumerated() {
            category.fetchMetadata(batch: 1) { error in
                guard error == nil else { callback(nil, error); return }
                callback(index, nil)
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
extension VODViewModel: PreviewAssetCellConfig {
    func rowHeight(index: Int) -> CGFloat {
        let category = categories[index]
        return (category.preferredCellSize.height + 2*category.previewCellPadding)
    }
}

// MARK: - Fetch Metadata
extension VODViewModel {
    // MARK: Exposure Assets
}



