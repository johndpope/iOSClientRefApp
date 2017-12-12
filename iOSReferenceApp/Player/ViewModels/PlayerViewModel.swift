//
//  PlayerViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-06-09.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class PlayerViewModel {
    enum PlayRequest {
        case vod(assetId: String, metaData: Asset?)
        case live(channelId: String, metaData: Asset?)
        case program(programId: String, channelId: String, metaData: Asset?)
        case offline(assetId: String, metaData: Asset?)
        
        var metaData: Asset? {
            switch self {
            case .vod(assetId: _, metaData: let metadata): return metadata
            case .live(channelId: _, metaData: let metadata): return metadata
            case .program(programId: _, channelId: _, metaData: let metadata): return metadata
            case .offline(assetId: _, metaData: let metadata): return metadata
            }
        }
    }
    
    var onPlaybackRequested: (PlayRequest) -> Void = { _ in }
    fileprivate(set) var playRequest: PlayRequest?
    let sessionToken: SessionToken
    let environment: Environment
    
    var isScrubbing: Bool
    
    init(sessionToken: SessionToken, environment: Environment, playRequest: PlayRequest? = nil) {
        self.playRequest = playRequest
        self.sessionToken = sessionToken
        self.environment = environment
        isScrubbing = false
    }
    
    func request(playback request: PlayRequest) {
        self.playRequest = request
        onPlaybackRequested(request)
    }
    
    func timeFormat(time: Int64) -> String {
        let s:UInt64 = (time < 0 ? UInt64(-time) : UInt64(time)) / 1000
        
        let seconds = s % 60
        let minutes = (s / 60) % 60
        let hours = (s / 3600) % 24
        
        guard hours > 0 else {
            return (time<0 ? "-":"") + String(format: "%02d:%02d",minutes,seconds)
        }
        return (time<0 ? "-":"") + String(format: "%d:%02d:%02d", hours,minutes,seconds)
    }
}
