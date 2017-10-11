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
    
    @IBOutlet weak var ratingStarStackView: UIStackView!
    @IBOutlet weak var productionYearLabel: UILabel!
    @IBOutlet weak var parentalRatingLabel: UILabel!
    
    
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
    
    @IBOutlet weak var offlineStackView: UIStackView!
    
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
        viewModel.refreshAssetMetaData{ [weak self] error in
            if let error = error {
                self?.showMessage(title: "Refresh Asset Metadata", message: error.localizedDescription)
            }
            self?.refreshUserDataUI()
        }
    }
    
    func determineDownloadUIForAsset() {
        downloadStackView.isHidden = true
        downloadProgressStackView.isHidden = true
        offlineStackView.isHidden = true
        guard let assetId = viewModel.asset.assetId else { return }
        if let offline = downloadViewModel.offline(assetId: assetId) {
            offline.state{ [weak self] state in
                switch state {
                case .completed:
                    self?.transitionToDownloadCompletedUI(from: nil)
                case .notPlayable:
                    self?.freezeStartDownloadInProgressUI(frozen: true)
                    self?.configureDownloadTask(assetId: assetId) { [weak self] in
                        self?.freezeStartDownloadInProgressUI(frozen: false)
                    }
                    self?.togglePauseResumeDownload(paused: true)
                    self?.transitionToDownloadProgressUI(from: nil)
                }
            }
        }
        else {
            transitionToDownloadUI(from: nil)
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
        else if segue.identifier == Segue.segueOfflineToPlayer.rawValue {
            if let destination = segue.destination as? PlayerViewController, let assetId = sender as? String {
                destination.viewModel = PlayerViewModel(sessionToken: viewModel.sessionToken,
                                                        environment: viewModel.environment,
                                                        playRequest: .offline(assetId: assetId))
                destination.onDismissed = { [weak self] in
                    self?.refreshUserDataUI()
                }
            }
        }
    }
    
    fileprivate enum Segue: String {
        case segueDetailsToPlayer = "segueDetailsToPlayer"
        case segueOfflineToPlayer = "segueOfflineToPlayer"
    }
}

// MARK: - User Data
extension AssetDetailsViewController {
    func refreshUserDataUI() {
        let locale = "en"
        if let imageUrl = viewModel
            .images(locale: locale)
            .prefere(orientation: .landscape)
            .validImageUrls()
            .first {
            mainImageView.kf.setImage(with: imageUrl) { (_, error, _, _) in
                if let error = error {
                    print("Kingfisher error: ",error)
                }
            }
        }
        
        
        titleLabel.text = viewModel.anyTitle(locale: locale)
        descriptionTextLabel.text = viewModel.longestDescription(locale: locale)
        
        productionYearLabel.text = viewModel.productionYear
        
        parentalRatingLabel.text = viewModel.anyParentalRating(locale: locale)
        
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
        downloadViewModel.resume()
        togglePauseResumeDownload(paused: false)
        transitionToDownloadProgressUI(from: downloadStackView)
    }
    
    func configureDownloadTask(assetId: String, onPrepared: @escaping () -> Void) {
        downloadViewModel.download(assetId: assetId) { [weak self] downloadTask, entitlement, error in
            guard let entitlement = entitlement else {
                self?.showMessage(title: "Entitlement Error", message: error?.localizedDescription ?? "Unable to fetch entitlement")
                return
            }
            
            downloadTask?
                .should(autoStart: false)
                .onPrepared{ _ in
                    onPrepared()
                }
                .onStarted { [weak self] task in
                    self?.downloadViewModel.save(assetId: assetId, entitlement: entitlement, url: nil)
                    self?.togglePauseResumeDownload(paused: false)
                }
                .onSuspended { [weak self] task in
                    self?.togglePauseResumeDownload(paused: true)
                }
                .onResumed { [weak self] task in
                    self?.togglePauseResumeDownload(paused: false)
                }
                .onProgress { [weak self] task, progress in
                    print("📱 Percent",progress.current*100,"%")
                    self?.update(downloadProgress: progress)
                }
                .onShouldDownloadMediaOption{ task, options in
                    print("📱 Select media option")
                    return nil
                }
                .onDownloadingMediaOption{ task, option in
                    print("📱 Downloading media option")
                }
                .onCanceled { [weak self] task, url in
                    self?.downloadViewModel.remove(assetId: assetId, clearing: url)
                    self?.transitionToDownloadUI(from: self?.downloadProgressStackView)
                }
                .onError { [weak self] task, url, error in
                    print("📱 Download error: \(error)")
                    self?.downloadViewModel.remove(assetId: assetId, clearing: url)
                    // TODO: Display error
                    self?.transitionToDownloadUI(from: self?.downloadProgressStackView)
                    self?.showMessage(title: "Download Error", message: error.localizedDescription)
                }
                .onCompleted { [weak self] task, url in
                    print("📱 Download completed: \(url)")
                    self?.downloadViewModel.save(assetId: assetId, entitlement: entitlement, url: url)
                    self?.transitionToDownloadCompletedUI(from: self?.downloadProgressStackView)
                }
                .prepare()
        }
    }
    
    func transitionToDownloadUI(from otherView: UIStackView?) {
        togglePauseResumeDownload(paused: false)
        // TODO: "Disable/Freeze" download UI when the download action is taken. This ensures multiple downloads are not started at the same time. NOTE: This needs to be "un-frozen" in case of errors etc.
        freezeStartDownloadUI(frozen: true)
        
        downloadQualityStackView.alpha = 0
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.downloadStackView.isHidden = false
            otherView?.isHidden = true
        }
        
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
        guard let assetId = viewModel.asset.assetId else { return }
        configureDownloadTask(assetId: assetId) { [weak self] in
            // Download is prepared, unfreeze UI
            self?.freezeStartDownloadUI(frozen: false)
        }
        
        if downloadViewModel.hasQualityOptions, let availableOptions = downloadViewModel.downloadQualityOptions {
            downloadQualitySelector.minimumValue = 0
            downloadQualitySelector.maximumValue = Float(availableOptions-1)
            downloadedSizeLabel.text = " "
            
            
            if downloadViewModel.selectedQualityIndex == nil { downloadViewModel.select(downloadQuality: 0) }
            let selectedQualityIndex = downloadViewModel.selectedQualityIndex!
            
            downloadQualitySelector.setValue(Float(selectedQualityIndex), animated: true)
            
            // Configure Slider
            update(downloadQuality: downloadViewModel.downloadQuality(for: selectedQualityIndex))
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.downloadQualityStackView.alpha = 1
            }
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
        downloadViewModel.cancel()
    }
    
    @IBAction func pauseResumeDownloadAction(_ sender: UIButton) {
        switch downloadViewModel.state {
        case .running: downloadViewModel.pause()
        case .suspended: downloadViewModel.resume()
        case .notStarted: downloadViewModel.resume()
        default: return
        }
    }
    
    func freezeStartDownloadInProgressUI(frozen: Bool) {
        downloadPauseResumeButton.isEnabled = !frozen
        // TODO Cancel button?
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
    
    func transitionToDownloadProgressUI(from otherView: UIStackView?) {
        downloadProgress.setProgress(0, animated: false)
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.downloadProgressStackView.isHidden = false
            otherView?.isHidden = true
        }
    }
    
    func startWithDownloadInProgressUI() {
        downloadProgress.setProgress(0, animated: false)
        downloadProgressStackView.isHidden = false
        downloadStackView.isHidden = true
        offlineStackView.isHidden = true
    }
    
    func update(downloadProgress progress: DownloadTask.Progress) {
        downloadedSizeLabel.text = downloadViewModel.downloadedSize(for: progress.current)
        downloadProgress.setProgress(Float(progress.current), animated: true)
    }
}

// MARK: - Offline Asset
extension AssetDetailsViewController {
    @IBAction func playOfflineAction(_ sender: UIButton) {
        guard let assetId = viewModel.asset.assetId else { return }
        self.performSegue(withIdentifier: Segue.segueOfflineToPlayer.rawValue, sender: assetId)
    }
    
    @IBAction func removeOfflineMediaAction(_ sender: UIButton) {
        guard let assetId = viewModel.asset.assetId else { return }
        downloadViewModel.remove(assetId: assetId)
        transitionToDownloadUI(from: offlineStackView)
    }
    
    @IBAction func viewOfflineListAction(_ sender: UIButton) {
    }
    
    func startWithDownloadCompleteUI() {
        self.offlineStackView.isHidden = false
        self.downloadProgressStackView.isHidden = true
        self.downloadStackView.isHidden = true
    }
    
    func transitionToDownloadCompletedUI(from otherView: UIStackView?) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.offlineStackView.isHidden = false
            otherView?.isHidden = true
        }
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
