//
//  AssetDetailsPresenter.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure

protocol AssetDetailsPresenter: class, AuthorizedEnvironment {
    var assetDetailsPresenter: UIViewController { get }
}

extension AssetDetailsPresenter {
    func presetDetails(for asset: Asset, from origin: AssetDetailsViewController.PresentedFrom) {
        guard let assetType = asset.type else {
            assetDetailsPresenter.showMessage(title: "AssetType missing", message: "Please check Exposure response")
            return
        }
        
        let uiStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = uiStoryboard.instantiateViewController(withIdentifier: "AssetDetailsViewController") as? AssetDetailsViewController {
            vc.bind(viewModel: AssetDetailsViewModel(asset: asset,
                                                     environment: environment,
                                                     sessionToken: sessionToken))
            vc.bind(downloadViewModel: DownloadAssetViewModel(environment: environment,
                                                              sessionToken: sessionToken))
            vc.presentedFrom = origin
            assetDetailsPresenter.present(vc, animated: true) { }
        }
    }
}
