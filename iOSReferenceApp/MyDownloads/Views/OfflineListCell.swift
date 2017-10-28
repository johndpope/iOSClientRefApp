//
//  OfflineListCell.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-19.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Kingfisher
import Exposure

class OfflineListCell: UITableViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    
    fileprivate var viewModel: OfflineListCellViewModel!
    var onPlaySelected: (OfflineMediaAsset) -> Void = { _ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(viewModel: OfflineListCellViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.anyTitle(locale: "en")
        sizeLabel.text = viewModel.downloadSize
        expirationLabel.text = viewModel.expiration
        
        if let metaData = ExposureSessionManager
            .shared
            .manager
            .retrieveMetaData(for: viewModel.offlineAsset.assetId) {
            let url = metaData
                .localized?
                .flatMap{ $0.images ?? []}
                .prefere(orientation: .portrait)
                .validImageUrls()
                .first
            thumbnailView.kf.setImage(with: url, options: [.onlyFromCache, .processor(thumbnailImageProcessor)])
        }
    }
    
    private var thumbnailImageProcessor: ImageProcessor {
        let resizeProcessor = CrispResizingImageProcessor(referenceSize: viewModel.preferredThumbnailSize, mode: ContentMode.aspectFill)
        let croppingProcessor = CroppingImageProcessor(size: viewModel.preferredThumbnailSize)
        let roundedRectProcessor = RoundCornerImageProcessor(cornerRadius: 6)
        return (resizeProcessor>>croppingProcessor)>>roundedRectProcessor
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        onPlaySelected(viewModel.offlineAsset)
    }
    
    @IBAction func showDetailsAction(_ sender: UIButton) {
        
    }
}
