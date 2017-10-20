//
//  EPGDetailsViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-07-10.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure

class EPGDetailsViewModel {
    fileprivate(set) var content: [ProgramViewModel] = []
    
    var environment: Environment
    var sessionToken: SessionToken
    func authorize(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
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

extension EPGDetailsViewModel: LocalizedAssetEntity {
    var asset: Asset {
        return channelAsset
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
