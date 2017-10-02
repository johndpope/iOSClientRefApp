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
import Download

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
            vc.bind(downloadViewModel: DownloadAssetViewModel(environment: environment,
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
    
    @IBOutlet weak var progressStackView: UIStackView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var durationLabel: UILabel!
    
    
    @IBOutlet weak var descriptionTextLabel: UILabel!
    @IBOutlet weak var footerTextLabel: UILabel!
    
    
    @IBOutlet weak var downloadStackView: UIStackView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var downloadQualityStackView: UIStackView!
    @IBOutlet weak var downloadQualitySelector: UISlider!
    @IBOutlet weak var downloadQualityLabel: UILabel!
    @IBOutlet weak var downloadSizeLabel: UILabel!
    
    @IBOutlet weak var downloadProgressStackView: UIStackView!
    @IBOutlet weak var downloadPauseResumeLabel: UILabel!
    @IBOutlet weak var downloadPauseResumeButton: UIButton!
    @IBOutlet weak var downloadProgress: UIProgressView!
    @IBOutlet weak var downloadedSizeLabel: UILabel!
    
    
    
    fileprivate(set) var viewModel: AssetDetailsViewModel!
    fileprivate(set) var downloadViewModel: DownloadAssetViewModel!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        defer { refreshUserDataUI() }
        
        determineDownloadUIForAsset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.refreshAssetMetaData{ [weak self] success in
            if success {
                self?.refreshUserDataUI()
            }
        }
    }
    
    func determineDownloadUIForAsset() {
        // 1. Check if available locally
        let notDownloaded = true
        let downloadInProgress = false
        let downloaded = false
        //
        // 2. Not downloaded
        //      2.1 displayStartDownloadUI()
        //
        // 3. Download in progress
        //      3.1 displayDownloadInProgressUI()
        //
        // 4. Downloaded
        //      4.1 displayAssetDownloadedUI()
        
        if notDownloaded {
            displayStartDownloadUI()
        }
        else if downloadInProgress {
            displayDownloadInProgressUI()
        }
        else if downloaded {
            displayAssetDownloadedUI()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bind(viewModel: AssetDetailsViewModel) {
        self.viewModel = viewModel
    }
    
    func bind(downloadViewModel: DownloadAssetViewModel) {
        self.downloadViewModel = downloadViewModel
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
}

extension AssetDetailsViewController {
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.segueDetailsToPlayer.rawValue {
            if let destination = segue.destination as? PlayerViewController, let assetId = sender as? String {
                destination.viewModel = PlayerViewModel(sessionToken: viewModel.sessionToken,
                                                        environment: viewModel.environment,
                                                        playRequest: .vod(assetId: assetId))
                destination.onDismissed = { [weak self] in
                    self?.refreshUserDataUI()
                }
            }
        }
    }
    
    fileprivate enum Segue: String {
        case segueDetailsToPlayer = "segueDetailsToPlayer"
    }
}

// MARK: - User Data
extension AssetDetailsViewController {
    func refreshUserDataUI() {
        if let imageUrl = viewModel
            .images(locale: "en")
            .prefere(orientation: .landscape)
            .validImageUrls()
            .first {
            mainImageView.kf.setImage(with: imageUrl) { (_, error, _, _) in
                if let error = error {
                    print("Kingfisher error: ",error)
                }
            }
        }
        
        titleLabel.text = viewModel.anyTitle(locale: "en")
        descriptionTextLabel.text = viewModel.longestDescription(locale: "en")
        
        // Update last viewed progress
        update(lastViewedOffset: viewModel.lastViewedOffset)
    }
    
    func update(lastViewedOffset: AssetDetailsViewModel.LastViewedOffset?) {
        progressStackView.isHidden = lastViewedOffset == nil
        progressLabel.text = lastViewedOffset?.currentOffset
        progressBar.setProgress(lastViewedOffset?.progress ?? 0, animated: false)
        durationLabel.text = lastViewedOffset?.duration
    }
}

// MARK: - Download available
extension AssetDetailsViewController {
    @IBAction func selectBitrate(_ sender: UISlider) {
        downloadViewModel.select(downloadQuality: Int(sender.value))
    }
    
    @IBAction func bitrateSelectionChanged(_ sender: UISlider) {
        let discreteValue = Int(sender.value)
        downloadQualitySelector.setValue(Float(discreteValue), animated: true)
        
        update(downloadQuality: downloadViewModel.downloadQuality(for: discreteValue))
    }
    
    @IBAction func downloadAction(_ sender: UIButton) {
        guard let assetId = viewModel.asset.assetId else { return }
        
        // TODO: "Disable/Freeze" download UI when the download action is taken. This ensures multiple downloads are not started at the same time. NOTE: This needs to be "un-frozen" in case of errors etc.
        freezeStartDownloadUI(frozen: true)
        
        downloadViewModel.download(assetId: assetId) { downloadTask, entitlement, error in
            // TODO: Store entitlement?
            
            downloadTask?
                .onStarted { [weak self] task in
                    self?.displayDownloadInProgressUI()
                }
                .onSuspended { [weak self] task in
                    self?.togglePauseResumeDownload(paused: true)
                }
                .onResumed { [weak self] task in
                    self?.togglePauseResumeDownload(paused: false)
                }
                .onProgress { [weak self] task, progress in
                    print("Percent",progress.current*100,"%")
                    self?.update(downloadProgress: progress)
                }
                .onShouldDownloadMediaOption{ task, options in
                    print("Select media option")
                    return nil
                }
                .onDownloadingMediaOption{ task, option in
                    print("Downloading media option")
                }
                .onCanceled { [weak self] task in
                    // TODO: Clean up downloaded media
                    self?.displayStartDownloadUI()
                }
                .onError { [weak self] (task, error) in
                    // TODO: Clean up downloaded media
                    // TODO: Display error
                    self?.displayStartDownloadUI()
                    self?.showMessage(title: "Download Error", message: error.localizedDescription)
                }
                .onCompleted { [weak self] (task, url) in
                    // TODO: Store URL somewhere
                    self?.displayAssetDownloadedUI()
                }
                .resume()
        }
    }
    
    func displayStartDownloadUI() {
        downloadStackView.isHidden = true
        
        // Hide other ui
        downloadProgressStackView.isHidden = true
        // TODO: Hide AssetDownloaded UI
        
        guard let assetId = viewModel.asset.assetId else { return }
        downloadViewModel.refreshDownloadMetadata(for: assetId) { [weak self] success in
            if success {
                self?.resetStartDownloadUI()
            }
        }
    }
    
    func freezeStartDownloadUI(frozen: Bool) {
        downloadButton.isEnabled = !frozen
        downloadQualitySelector.isEnabled = !frozen
    }
    
    private func resetStartDownloadUI() {
        freezeStartDownloadUI(frozen: false)
        
        togglePauseResumeDownload(paused: false)
        
        downloadStackView.isHidden = false
        
        if downloadViewModel.hasQualityOptions, let availableOptions = downloadViewModel.downloadQualityOptions {
            downloadQualityStackView.isHidden = false
            downloadQualitySelector.minimumValue = 0
            downloadQualitySelector.maximumValue = Float(availableOptions-1)
            downloadedSizeLabel.text = " "
            
            let selectedQualityIndex = downloadViewModel.selectedQualityIndex ?? 0
            
            
            downloadQualitySelector.setValue(Float(selectedQualityIndex), animated: true)
            
            // Configure Slider
            update(downloadQuality: downloadViewModel.downloadQuality(for: selectedQualityIndex))
        }
        else {
            downloadQualityStackView.isHidden = true
        }
    }
    
    func update(downloadQuality: DownloadAssetViewModel.DownloadQuality) {
        downloadSizeLabel.text = downloadQuality.size
        downloadQualityLabel.text = downloadQuality.bitrate
    }
}

// MARK: - Download in progress
extension AssetDetailsViewController {
    @IBAction func cancelDownloadAction(_ sender: UIButton) {
        switch downloadViewModel.state {
        case .running: downloadViewModel.cancel()
        case .suspended: downloadViewModel.cancel()
        default: return
        }
    }
    
    @IBAction func pauseResumeDownloadAction(_ sender: UIButton) {
        switch downloadViewModel.state {
        case .running: downloadViewModel.pause()
        case .suspended: downloadViewModel.resume()
        default: return
        }
    }
    
    func togglePauseResumeDownload(paused: Bool) {
        if paused {
            downloadPauseResumeLabel.text = "Resume"
            downloadPauseResumeButton.setImage(#imageLiteral(resourceName: "download"), for: [])
        }
        else {
            downloadPauseResumeLabel.text = "Pause"
            downloadPauseResumeButton.setImage(#imageLiteral(resourceName: "download-pause"), for: [])
        }
    }
    
    func displayDownloadInProgressUI() {
        downloadProgress.setProgress(0, animated: false)
        
        downloadStackView.isHidden = true
        downloadProgressStackView.isHidden = false
        // TODO: Hide AssetDownloaded UI
    }
    
    func update(downloadProgress progress: DownloadTask.Progress) {
        downloadedSizeLabel.text = downloadViewModel.downloadedSize(for: progress.current)
        downloadProgress.setProgress(Float(progress.current), animated: true)
    }
}

// MARK: - Downloaded Asset
extension AssetDetailsViewController {
    func displayAssetDownloadedUI() {
        
    }
}

// MARK: - AuthorizedEnvironment
extension AssetDetailsViewController: AuthorizedEnvironment {
    var environment: Environment {
        return viewModel.environment
    }
    
    var sessionToken: SessionToken {
        return viewModel.sessionToken
    }
}
