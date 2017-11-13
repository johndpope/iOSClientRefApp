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

class AssetDetailsViewController: UIViewController {
    
    @IBOutlet weak var scrollView: LazyScrollView!
    @IBOutlet weak var contentStackView: UIStackView!
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var ratingStarStackView: UIStackView!
    @IBOutlet weak var productionYearLabel: UILabel!
    @IBOutlet weak var parentalRatingLabel: UILabel!
    
    
    @IBOutlet weak var progressStackView: UIStackView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var participantsStackView: UIStackView!
    
    @IBOutlet weak var descriptionTextLabel: UILabel!
    @IBOutlet weak var footerTextLabel: UILabel!
    
    
    @IBOutlet weak var downloadStackView: UIStackView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var downloadQualityStackView: UIStackView!
    @IBOutlet weak var downloadQualitySelector: UISlider!
    @IBOutlet weak var downloadQualityLabel: UILabel!
    @IBOutlet weak var downloadSizeLabel: UILabel!
    
    @IBOutlet weak var downloadProgressStackView: UIStackView!
    @IBOutlet weak var downloadPauseResumeButton: UIButton!
    @IBOutlet weak var downloadProgress: UIProgressView!
    @IBOutlet weak var downloadedSizeLabel: UILabel!
    
    @IBOutlet weak var offlineStackView: UIStackView!
    
    var brand: Branding.ColorScheme = Branding.ColorScheme.default
    fileprivate(set) var viewModel: AssetDetailsViewModel!
    fileprivate(set) var downloadViewModel: DownloadAssetViewModel!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var presentedFrom: PresentedFrom = .other
    enum PresentedFrom {
        case offlineList
        case other
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        defer { refreshUserDataUI() }
        loadAssetMetaData()
        determineDownloadUIForAsset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apply(brand: brand)
        viewModel.refreshAssetMetaData{ [weak self] error in
            if let error = error {
                self?.showMessage(title: "Refresh Asset Metadata", message: error.localizedDescription)
            }
            self?.refreshUserDataUI()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait //return the value as per the required orientation
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    func determineDownloadUIForAsset() {
        downloadStackView.isHidden = true
        downloadProgressStackView.isHidden = true
        offlineStackView.isHidden = true
        guard let assetId = viewModel.asset.assetId else { return }
        if downloadViewModel.offline(assetId: assetId) != nil {
            configureDownloadTask(assetId: assetId, lazily: true, autostart: false)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: contentStackView.frame.width, height: contentStackView.frame.height)
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
                destination.brand = brand
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
                destination.brand = brand
                destination.onDismissed = { [weak self] in
                    self?.refreshUserDataUI()
                }
            }
        }
        else if segue.identifier == Segue.segueDetailsToList.rawValue {
            if let navController = segue.destination as? UINavigationController, let destination = navController.topViewController as? OfflineListViewController {
                destination.authorize(environment: environment,
                                      sessionToken: sessionToken)
                // Scroll to the current asset (if applicable)
                let scrollTo = viewModel.asset
                
                // Hook the callback
                destination.presentedFrom = .assetDetails(onSelected: { [weak self] offlineMedia, asset in
                    if let newAsset = asset {
                        self?.viewModel.asset = newAsset
                        self?.loadAssetMetaData()
                        self?.determineDownloadUIForAsset()
                    }
                })
            }
        }
    }
    
    fileprivate enum Segue: String {
        case segueDetailsToPlayer = "segueDetailsToPlayer"
        case segueOfflineToPlayer = "segueOfflineToPlayer"
        case segueDetailsToList = "segueDetailsToList"
    }
}

// MARK: - User Data
extension AssetDetailsViewController {
    func loadAssetMetaData() {
        let locale = "en"
        if let imageUrl = viewModel
            .images(locale: locale)
            .prefere(orientation: .square)
            .validImageUrls()
            .first {
            mainImageView.kf.setImage(with: imageUrl) { [weak self] (image, error, _, _) in
                if let error = error {
                    print("Kingfisher error: ",error)
                }
            }
        }
        
        titleLabel.text = viewModel.anyTitle(locale: locale)
        descriptionTextLabel.text = viewModel.anyDescription(locale: locale)
        footerTextLabel.text = ""
        
        productionYearLabel.text = viewModel.productionYear
        
        parentalRatingLabel.text = viewModel.anyParentalRating(locale: locale)
        
        assignParticipants()
    }
    func refreshUserDataUI() {
        // Update last viewed progress
        update(lastViewedOffset: viewModel.lastViewedOffset)
    }
    
    func update(lastViewedOffset: AssetDetailsViewModel.LastViewedOffset?) {
        progressStackView.isHidden = lastViewedOffset == nil
        progressLabel.text = lastViewedOffset?.currentOffset
        progressBar.setProgress(lastViewedOffset?.progress ?? 0, animated: false)
        durationLabel.text = lastViewedOffset?.duration
    }
    
    private func assignParticipants() {
        let current = participantsStackView.subviews
        current.forEach{
            participantsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        viewModel.participantGroups()
            .sorted{ $0.function < $1.function }
            .map{ group -> UILabel in
                let label = UILabel()
                let function = (group.function + (group.names.count > 1 ? "s: " : ": ")).capitalized
                
                let names = group.names.joined(separator: ", ")
                
                label.font = UIFont(name: "Helvetica Neue", size: 14)
                label.textColor = brand.text.secondary
                label.lineBreakMode = NSLineBreakMode.byWordWrapping
                label.numberOfLines = 0
                label.text = function + names
                return label
            }
            .forEach{
                participantsStackView.addArrangedSubview($0)
        }
        participantsStackView.layoutIfNeeded()
    }
}

extension UIImageView {
    
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
        configureDownloadTask(assetId: assetId, lazily: false, autostart: true)
        downloadViewModel.persist(metaData: viewModel.asset)
        togglePauseResumeDownload(paused: false)
    }
    
    func configureDownloadTask(assetId: String, lazily: Bool, autostart: Bool) {
        
        let downloadTask = downloadViewModel.createDownloadTask(for: assetId)
            .onEntitlementRequestStarted{ [weak self] task in
                self?.togglePauseResumeDownload(paused: false)
            }
            .onEntitlementResponse{ task, entitlement in
                // Optionally store it somewhere
                print("📱 Entitlement successfully requested")
            }
            .onEntitlementRequestCancelled{ [weak self] task in
                self?.showMessage(title: "Entitlement Request", message: "Cancelled by User")
            }
            .onPrepared { [weak self] task in
                print("📱 Media Download prepared")
                self?.transitionToDownloadProgressUI(from: self?.downloadStackView)
                if autostart {
                    print("📱 Autostarting download")
                    task.resume()
                }
            }
            .onSuspended { [weak self] task in
                print("📱 Media Download suspended")
                self?.togglePauseResumeDownload(paused: true)
            }
            .onResumed { [weak self] task in
                print("📱 Media Download resumed")
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
                print("📱 Download cancelled: \(url)")
                self?.downloadViewModel.remove(assetId: assetId)
                self?.transitionToDownloadUI(from: self?.downloadProgressStackView)
            }
            .onError { [weak self] task, url, error in
                print("📱 Download error: \(error)")
                self?.downloadViewModel.remove(assetId: assetId)
                // TODO: Display error
                self?.transitionToDownloadUI(from: self?.downloadProgressStackView)
                self?.showMessage(title: "Download Error", message: error.localizedDescription)
            }
            .onCompleted { [weak self] task, url in
                print("📱 Download completed: \(url)")
                self?.transitionToDownloadCompletedUI(from: self?.downloadProgressStackView)
            }
            .prepare(lazily: lazily)
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
            else {
                self?.downloadStackView.isHidden = true
            }
        }
    }
    
    func freezeStartDownloadUI(frozen: Bool) {
        downloadButton.isEnabled = !frozen
        downloadQualitySelector.isEnabled = !frozen
    }
    
    private func resetStartDownloadUI() {
        freezeStartDownloadUI(frozen: false)
        
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
            downloadPauseResumeButton.setImage(#imageLiteral(resourceName: "download"), for: [])
        }
        else {
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
    
    func update(downloadProgress progress: Download.Progress) {
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
        switch presentedFrom {
        case .offlineList: dismiss(animated: true)
        case .other: performSegue(withIdentifier: Segue.segueDetailsToList.rawValue, sender: nil)
        }
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
    func authorize(environment: Environment, sessionToken: SessionToken) {
        viewModel.authorize(environment: environment, sessionToken: sessionToken)
    }
    var environment: Environment {
        return viewModel.environment
    }
    
    var sessionToken: SessionToken {
        return viewModel.sessionToken
    }
}

extension AssetDetailsViewController: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        progressLabel.textColor = brand.accent
        progressBar.apply(brand: brand)
        durationLabel.textColor = brand.text.primary
        
        downloadQualitySelector.apply(brand: brand)
        downloadQualityLabel.textColor = brand.text.primary
        
        downloadSizeLabel.textColor = brand.text.primary
        downloadProgress.apply(brand: brand)
        downloadedSizeLabel.textColor = brand.text.primary
        
        descriptionTextLabel.textColor = brand.text.primary
        descriptionTextLabel.textColor = brand.text.primary
        descriptionTextLabel.textColor = brand.text.primary
        
        participantsStackView.arrangedSubviews.forEach{
            if let label = $0 as? UILabel {
                label.textColor = brand.text.secondary
            }
        }
        
        footerTextLabel.textColor = brand.text.secondary
        
        productionYearLabel.textColor = brand.text.secondary
        parentalRatingLabel.textColor = brand.text.secondary
    }
}
