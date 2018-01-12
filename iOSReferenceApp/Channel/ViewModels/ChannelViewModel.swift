//
//  ChannelViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-06.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class ChannelViewModel {
    var asset: Asset!
    fileprivate(set) var content: [PresentableViewModel<Program>] = []
    
    var environment: Environment
    var sessionToken: SessionToken
    
    var epgAvailable: Bool {
        return !content.isEmpty
    }
    
    init(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
}

extension ChannelViewModel {
    func currentlyLive() -> IndexPath? {
        for index in (0..<content.count) {
            let program = content[index]
            if program.isLive { return IndexPath(row: index, section: 0) }
        }
        return nil
    }
    
    var channelId: String {
        return asset.assetId ?? "CHANNEL_ID_NOT_FOUND"
    }
    
    func rowHeight(index: Int) -> CGFloat {
        return 72
    }
}

extension ChannelViewModel {
    func fetchEPG(starting: Date?, ending: Date, callback: @escaping (ExposureError?) -> Void) {
        FetchEpg(environment: environment)
            .channel(id: channelId)
            .show(page: 1, spanning: 100)
            .filter(starting: starting, ending: ending)
            .request()
            .validate()
            .response{ [weak self] in
                if let success = $0.value {
                    self?.processResponse(epg: success)
                    callback(nil)
                }
                
                if let error = $0.error {
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
            .flatMap{ PresentableViewModel(model: $0) }
        
        content.append(contentsOf: vms)
    }
}
