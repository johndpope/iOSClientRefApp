//
//  EPGDetailsViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-07-10.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure

class EPGDetailsViewModel: EntitlementRequester {
    fileprivate(set) var content: [ProgramViewModel] = []
    
    let environment: Environment
    let sessionToken: SessionToken
    let channelAsset: Asset
    init(channelAsset: Asset, environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
        self.channelAsset = channelAsset
    }
    
    var channelId: String {
        return channelAsset.assetId ?? "CHANNEL_ID_NOT_FOUND"
    }
    
    lazy fileprivate var request: FetchEpgChannel = { [unowned self] in
        return FetchEpg(environment: self.environment)
            .channel(id: self.channelId)
        }()
    
    func rowHeight(index: Int) -> CGFloat {
        return 72
    }
}

extension EPGDetailsViewModel: LocalizedEntity {
    var locales: [String] {
        return channelAsset.localized?.flatMap{ $0.locale } ?? []
    }
    
    func localizedData(locale: String) -> LocalizedData? {
        return channelAsset.localized?.filter{ $0.locale == locale }.first
    }
    
    func localizations() -> [LocalizedData] {
        return channelAsset.localized ?? []
    }
    
    func anyTitle(locale: String) -> String {
        if let title = title(locale: locale) { return title }
        else if let originalTitle = channelAsset.originalTitle { return originalTitle }
        else if let assetId = channelAsset.assetId { return assetId }
        return "CHANNEL"
    }
}

extension EPGDetailsViewModel {
    func fetchEPG(starting: Date?, ending: Date, callback: @escaping (ExposureError?) -> Void) {
        request
            .show(page: 1, spanning: 100)
            .filter(starting: starting, ending: ending)
            .request()
            .validate()
            .response{ [weak self] (exposure: ExposureResponse<ChannelEpg>) in
                if let success = exposure.value {
                    self?.processResponse(epg: success)
                    callback(nil)
                }
                
                if let error = exposure.error {
                    callback(error)
                    print(error)
                }
        }
    }
    
    fileprivate func processResponse(epg: ChannelEpg) {
        guard let programs = epg.programs else {
            return
        }
        
        let vms = programs
            .flatMap{ ProgramViewModel(program: $0) }
        
        content.append(contentsOf: vms)
    }
}

extension EPGDetailsViewModel {
    func currentlyLive() -> IndexPath? {
        for index in (0..<content.count) {
            let program = content[index]
            if program.isLive { return IndexPath(row: index, section: 0) }
        }
        return nil
    }
}
