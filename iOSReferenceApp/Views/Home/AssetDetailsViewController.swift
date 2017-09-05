//
//  AssetDetailsViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-06-01.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure
import Kingfisher
import Player
import AVKit

protocol AssetDetailsPresenter: class, AuthorizedEnvironment {
    var assetDetailsPresenter: UIViewController { get }
}

extension AssetDetailsPresenter {
    func presetDetails(for asset: Asset) {
        guard let assetType = asset.type else {
            assetDetailsPresenter.showMessage(title: "AssetType missing", message: "Please check Exposure response")
            return
        }
        
        switch assetType {
        case .tvChannel: presentEPG(for: asset)
        default: presentVod(for: asset)
        }
    }
    
    fileprivate func presentVod(for asset: Asset) {
        let uiStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = uiStoryboard.instantiateViewController(withIdentifier: "AssetDetailsViewController") as? AssetDetailsViewController {
            vc.bind(viewModel: AssetDetailsViewModel(asset: asset,
                                                     environment: environment,
                                                     sessionToken: sessionToken))
            assetDetailsPresenter.present(vc, animated: true) { }
        }
    }
    
    fileprivate func presentEPG(for asset: Asset) {
        guard asset.assetId != nil else {
            assetDetailsPresenter.showMessage(title: "ChannelId missing", message: "Please check Exposure response")
            return
        }
        
        let uiStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = uiStoryboard.instantiateViewController(withIdentifier: "EPGDetailsViewController") as? EPGDetailsViewController {
            vc.bind(viewModel: EPGDetailsViewModel(channelAsset: asset,
                                                   environment: environment,
                                                   sessionToken: sessionToken))
            assetDetailsPresenter.present(vc, animated: true) { }
        }
    }
}

class AssetDetailsViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingsView: UIView!
    @IBOutlet weak var descriptionTextLabel: UILabel!
    @IBOutlet weak var footerTextLabel: UILabel!
    
    fileprivate(set) var viewModel: AssetDetailsViewModel!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let imageUrl = viewModel.validImageUrls(locale: "en").first {
            mainImageView.kf.setImage(with: imageUrl) { (_, error, _, _) in
                if let error = error {
                    print("Kingfisher error: ",error)
                }
            }
        }
        
        titleLabel.text = viewModel.anyTitle(locale: "en")
        descriptionTextLabel.text = viewModel.longestDescription(locale: "en")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bind(viewModel: AssetDetailsViewModel) {
        self.viewModel = viewModel
    }

    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        guard let assetId = viewModel.asset.assetId else {
            showMessage(title: "Invalid Asset", message: "AssetId missing, unable to perform playback")
            return
        }
        
        self.performSegue(withIdentifier: Segue.segueDetailsToPlayer.rawValue, sender: assetId)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.segueDetailsToPlayer.rawValue {
            if let destination = segue.destination as? PlayerViewController, let assetId = sender as? String {
                destination.viewModel = PlayerViewModel(sessionToken: viewModel.sessionToken,
                                                        environment: viewModel.environment,
                                                        playRequest: .vod(assetId: assetId))
            }
        }
    }
    
    fileprivate enum Segue: String {
        case segueDetailsToPlayer = "segueDetailsToPlayer"
    }
}

extension AssetDetailsViewController: AuthorizedEnvironment {
    var environment: Environment {
        return viewModel.environment
    }
    
    var sessionToken: SessionToken {
        return viewModel.sessionToken
    }
}
