//
//  TVViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure
import GoogleCast
import Cast

protocol ChromeCaster: GCKSessionManagerListener, GCKRemoteMediaClientListener {
    var castSession: GCKCastSession? { get set }
    var castChannel: Channel { get set }
    
    var castEnvironment: Cast.Environment { get }
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
    
    func loadChromeCast(assetId: String, programId: String?, metaData: Asset?) {
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
        
        let customData = Cast.CustomData(environment: castEnvironment,
                                         assetId: assetId,
                                         programId: programId,
                                         useLastViewedOffset: true)
        let mediaInfo = GCKMediaInformation(contentID: assetId,
                                            streamType: .none,
                                            contentType: "video/mp4",
                                            metadata: chromeCastMetaData(from: metaData),
                                            streamDuration: 0,
                                            mediaTracks: nil,
                                            textTrackStyle: nil,
                                            customData: nil)
        
        let mediaLoadOptions = GCKMediaLoadOptions()
        mediaLoadOptions.customData = customData.toJson
        
        session
            .remoteMediaClient?
            .loadMedia(mediaInfo, with: mediaLoadOptions)
    }
}

class TVViewController: UIViewController {

    var viewModel: ChannelListViewModel!
    var brand: Branding.ColorScheme = Branding.ColorScheme.default
    var slidingMenuController: SlidingMenuController?
    var dynamicContentCategory: DynamicContentCategory?
    
    fileprivate var embeddedPlayerController: PlayerViewController?
    fileprivate weak var playerViewModel: PlayerViewModel?
    
    fileprivate var embeddedEpgController: PagedEPGViewController?
    
    @IBOutlet weak var castButton: GCKUICastButton!
    var castChannel: Channel = Channel()
    var castSession: GCKCastSession?
    
    var hasActiveChromecastSession: Bool {
        return GCKCastContext.sharedInstance().sessionManager.hasConnectedCastSession()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let conf = dynamicContentCategory {
//            embeddedPlayerController.dynamicContentCategory = conf
            embeddedEpgController?.dynamicContentCategory = conf
        }
        
        let castButton = GCKUICastButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0),
                                                       width: CGFloat(24), height: CGFloat(24)))
        castButton.apply(brand: brand)
        var navItems = navigationItem.rightBarButtonItems
        navItems?.append(UIBarButtonItem(customView: castButton))
        navigationItem.rightBarButtonItems = navItems
        
        apply(brand: brand)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleSlidingMenuAction(_ sender: UIBarButtonItem) {
        slidingMenuController?.toggleSlidingMenu()
    }
}
extension TVViewController: ChromeCaster {
    var castEnvironment: Cast.Environment {
        return Cast.Environment(baseUrl: viewModel.environment.baseUrl,
                                customer: viewModel.environment.customer,
                                businessUnit: viewModel.environment.businessUnit,
                                sessionToken: viewModel.sessionToken.value)
    }
}

extension TVViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embeddedPlayerView" {
            if let destination = segue.destination as? PlayerViewController {
                embeddedPlayerController = destination
                destination.viewModel = PlayerViewModel(sessionToken: viewModel.sessionToken,
                                                        environment: viewModel.environment)
                destination.brand = brand
                destination.presentationMode = .embedded
                playerViewModel = destination.viewModel
//                destination.dynamicContentCategory = dynamicContentCategory
            }
        }
        else if segue.identifier == "embeddedEpgView" {
            if let destination = segue.destination as? PagedEPGViewController {
                embeddedEpgController = destination
                
                destination.viewModel = ChannelListViewModel(environment: viewModel.environment,
                                                             sessionToken: viewModel.sessionToken)
                destination.brand = brand
                destination.dynamicContentCategory = dynamicContentCategory
                destination.onPlaybackRequested = { [weak self] programId, channelId, metaData in
                    guard let `self` = self else { return }
                    if self.hasActiveChromecastSession {
                        self.loadChromeCast(assetId: channelId, programId: programId, metaData: metaData)
                    }
                    else {
                        if let programId = programId {
                            self.playerViewModel?.request(playback: .program(programId: programId, channelId: channelId))
                        }
                        else {
                            self.playerViewModel?.request(playback: .live(channelId: channelId))
                        }
                    }
                }
            }
        }
        else if segue.identifier == "segueToSearch" {
            if let destination = segue.destination as? SearchViewController {
                destination.authorize(environment: environment,
                                      sessionToken: sessionToken)
            }
        }
    }
}

extension TVViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let newMode: PlayerViewController.Mode = size.width > size.height ? .standalone : .embedded
        embeddedPlayerController?.presentationMode = newMode
        embeddedPlayerController?.configure(for: newMode)
    }
}

extension TVViewController: SlidingMenuDelegate { }

extension TVViewController: AuthorizedEnvironment {
    func authorize(environment: Exposure.Environment, sessionToken: SessionToken) {
        viewModel = ChannelListViewModel(environment: environment,
                                         sessionToken: sessionToken)
    }
    
    var environment: Exposure.Environment {
        return viewModel.environment
    }
    
    var sessionToken: SessionToken {
        return viewModel.sessionToken
    }
}


extension TVViewController: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        view.backgroundColor = brand.backdrop.primary
        
    }
}


extension TVViewController: GCKSessionManagerListener {
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKSession, withError error: Error?) {
        
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        print("Cast.Channel connected")
        session.add(castChannel)
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKCastSession) {
        print("Cast.Channel disconnected")
        session.remove(castChannel)
    }
}

extension TVViewController: GCKRemoteMediaClientListener {
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        castChannel.refreshControls()
    }
}
