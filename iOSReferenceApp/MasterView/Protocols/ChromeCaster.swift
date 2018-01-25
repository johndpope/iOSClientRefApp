//
//  ChromeCaster.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2018-01-25.
//  Copyright © 2018 emp. All rights reserved.
//

import UIKit
import Exposure
import GoogleCast
import Cast

protocol ChromeCaster: GCKSessionManagerListener, GCKRemoteMediaClientListener {
    var castSession: GCKCastSession? { get set }
    var castChannel: Channel { get set }
    
    var castEnvironment: Cast.Environment { get }
    var hasActiveChromecastSession: Bool { get }
}

extension ChromeCaster {
    fileprivate func chromeCastMetaData(from asset: Asset?) -> GCKMediaMetadata? {
        guard let asset = asset else { return nil }
        let data = GCKMediaMetadata(metadataType: .movie)
        data.setString(asset.anyTitle(locale: "en"), forKey: kGCKMetadataKeyTitle)
        data.setString(asset.anyDescription(locale: "en"), forKey: kGCKMetadataKeySubtitle)
        
        let images = asset.images(locale: "en").flatMap{ image -> GCKImage? in
            if let urlString = image.url, let url = URL(string: urlString), let width = image.width, let height = image.height {
                return GCKImage(url: url, width: width, height: height)
            }
            return nil
        }
        images.forEach{ data.addImage($0) }
        return data
    }
    
    func loadChromeCast(for request: PlayerViewModel.PlayRequest, localOffset: Int64?) {
        guard let session = GCKCastContext.sharedInstance().sessionManager.currentCastSession else { return }
        
        // Assign ChromeCast session listener
        GCKCastContext.sharedInstance().sessionManager.add(self)
        castSession = session
        session.add(castChannel)
        session.remoteMediaClient?.add(self)
        castChannel
            .onTracksUpdated { tracksUpdated in
                print("Cast.Channel onTracksUpdated Audio",tracksUpdated.audio)
                print("Cast.Channel onTracksUpdated Subs ",tracksUpdated.subtitles)
            }
            .onTimeshiftEnabled{ timeshift in
                print("Cast.Channel onTimeshiftEnabled",timeshift)
            }
            .onVolumeChanged { volumeChanged in
                print("Cast.Channel onVolumeChanged",volumeChanged)
            }
            .onDurationChanged { duration in
                print("Cast.Channel onDurationChanged",duration)
            }
            .onStartTimeLive{ startTime in
                print("Cast.Channel onStartTimeLive",startTime)
            }
            .onProgramChanged{ program in
                print("Cast.Channel onProgramChanged",program)
            }
            .onSegmentMissing{ segment in
                print("Cast.Channel onSegmentMissing",segment)
            }
            .onAutoplay { autoplay in
                print("Cast.Channel onAutoplay",autoplay)
            }
            .onIsLive { isLive in
                print("Cast.Channel onIsLive",isLive)
            }
            .onError{ error in
                print("Cast.Channel onError",error)
        }
        
        
        
        let customData = configure(for: request, localOffset: localOffset)
        let mediaInfo = GCKMediaInformation(contentID: assetId(for: request),
                                            streamType: .none,
                                            contentType: "video/mp4",
                                            metadata: chromeCastMetaData(from: request.metaData),
                                            streamDuration: 0,
                                            mediaTracks: nil,
                                            textTrackStyle: nil,
                                            customData: nil)
        
        let mediaLoadOptions = GCKMediaLoadOptions()
        mediaLoadOptions.customData = customData.toJson
        
        print(customData.toJson)
        
        session
            .remoteMediaClient?
            .loadMedia(mediaInfo, with: mediaLoadOptions)
    }
    
    private func configure(for request: PlayerViewModel.PlayRequest, localOffset: Int64?) -> Cast.CustomData {
        switch request {
        case .vod(assetId: let assetId, metaData: _):
            return CustomData(environment: castEnvironment,
                              assetId: assetId,
                              startTime: localOffset,
                              useLastViewedOffset: localOffset == nil)
        case .live(channelId: let channelId, metaData: _):
            return CustomData(environment: castEnvironment,
                              assetId: channelId,
                              absoluteStartTime: localOffset,
                              useLastViewedOffset: localOffset == nil)
        case .program(programId: let programId, channelId: let channelId, metaData: _):
            return CustomData(environment: castEnvironment,
                              assetId: channelId,
                              programId: programId,
                              startTime: localOffset,
                              useLastViewedOffset: localOffset == nil)
        case .offline(assetId: let assetId, metaData: _):
            return CustomData(environment: castEnvironment,
                              assetId: assetId,
                              startTime: localOffset,
                              useLastViewedOffset: localOffset == nil)
        }
    }
    
    private func assetId(for request: PlayerViewModel.PlayRequest) -> String {
        switch request {
        case .vod(assetId: let assetId, metaData: _): return assetId
        case .live(channelId: let assetId, metaData: _): return assetId
        case .program(programId: _, channelId: let assetId, metaData: _): return assetId
        case .offline(assetId: let assetId, metaData: _): return assetId
        }
    }
    
    var hasActiveChromecastSession: Bool {
        return GCKCastContext.sharedInstance().sessionManager.hasConnectedCastSession()
    }
}
