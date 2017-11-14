//
//  EPGPreviewCell.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-07-10.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class EPGPreviewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var liveProgressView: UIProgressView!
    fileprivate weak var viewModel: ProgramViewModel?
    fileprivate var liveProgressTimer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bind(viewModel: ProgramViewModel) {
        reset()
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.anyTitle(locale: "en")
        durationLabel.text = viewModel.programDurationString(locale: "en")
        
        
        if viewModel.isLive {
            updateLiveProgress(animated: false)
            trackLiveProgress()
        }
        
        if viewModel.isUpcoming {
            markAs(upcoming: true)
        }
        
        if let url = viewModel
            .images(locale: "en")
            .prefere(orientation: .landscape)
            .validImageUrls()
            .first {
            thumbnailView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "assetPlaceholder")) { (image, error, _, url) in
                if let error = error {
                    print("Kingfisher: ",error)
                }
            }
        }
    }
    
    func reset() {
        viewModel = nil
        liveProgressView.isHidden = true
        thumbnailView.image = #imageLiteral(resourceName: "assetPlaceholder")
        haltLiveProgress()
        markAs(upcoming: false)
    }
    
    func duration(string: String) {
        durationLabel.text = string
    }
}

/// Live
extension EPGPreviewCell {
    fileprivate func trackLiveProgress() {
        haltLiveProgress()
        
        liveProgressTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(EPGPreviewCell.trackerLiveProgressToggle), userInfo: nil, repeats: true)
    }
    
    fileprivate func haltLiveProgress() {
        if liveProgressTimer != nil {
            liveProgressTimer?.invalidate()
            liveProgressTimer = nil
            liveProgressView.isHidden = true
            liveProgressView.setProgress(0, animated: false)
        }
    }
    
    @objc fileprivate func trackerLiveProgressToggle() {
        if let isLive = viewModel?.isLive, isLive {
            updateLiveProgress(animated: true)
        }
        else {
            haltLiveProgress()
        }
    }
    
    fileprivate func updateLiveProgress(animated: Bool) {
        if let percent = self.viewModel?.programLiveProgress() {
            liveProgressView.isHidden = false
            liveProgressView.setProgress(percent, animated: animated)
        }
    }
}

/// Upcomming
extension EPGPreviewCell {
    fileprivate func markAs(upcoming: Bool) {
        titleLabel.textColor = upcoming ? UIColor.gray : UIColor.white
        durationLabel.textColor = upcoming ? UIColor.gray : UIColor.white
        thumbnailView.alpha = upcoming ? 0.5 : 1
    }
}


extension EPGPreviewCell: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        titleLabel.textColor = brand.text.primary
        durationLabel.textColor = brand.text.secondary
        liveProgressView.progressTintColor = brand.accent
        
        contentView.backgroundColor = brand.backdrop.primary
    }
}
