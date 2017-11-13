//
//  MainMenuViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure
import Kingfisher

class MainMenuViewModel {
    // MARK: Basics
    let environment: Environment
    let sessionToken: SessionToken
    
    var brand: Branding.ColorScheme = Branding.ColorScheme.default {
        didSet { sections.forEach { $0.brand = brand } }
    }
    
    var sections: [MainMenuSectionViewModel] = []
    
    subscript(index: Int) -> MainMenuSectionViewModel {
        get {
            return sections[index]
        }
    }
    
    
    subscript(indexPath: IndexPath) -> MainMenuItemType {
        get {
            return sections[indexPath.section].rows[indexPath.row]
        }
    }
    
    var homeContentViewModel: MainMenuContentViewModel {
        return sections[1].rows.first! as! MainMenuContentViewModel
    }
    
    init(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
    
    func configure() {
        let userPrefs = configureUserPreferences()
        let contentList = emptyContentList()
        let appSettings = configureAppSettings()
        
        sections = [userPrefs, contentList, appSettings]
    }
    
    private func configureUserPreferences() -> MainMenuSectionViewModel {
        let download = MainMenuPushNavigationViewModel(title: "My downloads", action: .other(segue: .myDownloads), image: #imageLiteral(resourceName: "download"))
        let favourites = MainMenuPushNavigationViewModel(title: "Favourites", action: .none, image: #imageLiteral(resourceName: "download-list"))
        return MainMenuSectionViewModel(rows: [download, favourites])
    }
    
    private func emptyContentList() -> MainMenuSectionViewModel {
        return MainMenuSectionViewModel(rows: [])
    }
    
    
    func updateDynamicContent(with dynamicConfig: DynamicCustomerConfig) {
        brand = dynamicConfig.colorScheme
        
        // TODO: This is where we parse all the different carousel categories
        let rows = fakeCarouselResponse(with: dynamicConfig.carouselGroupId)
        
        sections[1].rows = rows
        
        rows.forEach{ $0.brand = brand }
    }
    
    private func fakeCarouselResponse(with carouselId: String?) -> [MainMenuContentViewModel] {
        let home = MainMenuContentViewModel(dynamicContent: resolveHomeCategory(with: carouselId), active: true)
        let tv = MainMenuContentViewModel(dynamicContent: FakeDynamicContentCarousel(title: "TV", presentation: .tabbedEpg, content: .channels))
        let movies = MainMenuContentViewModel(dynamicContent: FakeDynamicContentCarousel(title: "Movies", presentation: .multiCarousel, content: .movies))
        let documentaries = MainMenuContentViewModel(dynamicContent: FakeDynamicContentCarousel(title: "Documentaries", presentation: .multiCarousel, content: .documentaries))
        let kids = MainMenuContentViewModel(dynamicContent: FakeDynamicContentCarousel(title: "Kids", presentation: .multiCarousel, content: .kids))
        let clips = MainMenuContentViewModel(dynamicContent: FakeDynamicContentCarousel(title: "Clips", presentation: .multiCarousel, content: .clips))
        let omegaPoint = MainMenuContentViewModel(dynamicContent: FakeDynamicContentCarousel(title: "Single Carousel", presentation: .singleCarousel, content: .clips))
        
        return [home, tv, movies, documentaries, kids, clips, omegaPoint]
    }
    
    private func resolveHomeCategory(with carouselId: String?) -> DynamicContentCategory {
        guard let carouselId = carouselId else {
            return FakeDynamicContentCarousel(title: "Home", presentation: .multiCarousel, content: .home)
        }
        return DynamicContentCarousel(title: "Home", presentation: .multiCarousel, contentId: carouselId)
    }
    
    private func configureAppSettings() -> MainMenuSectionViewModel {
        let appSettings = MainMenuPushNavigationViewModel(title: "App Settings", action: .none)
        let account = MainMenuPushNavigationViewModel(title: "Account", action: .none)
        let logOut = MainMenuPushNavigationViewModel(title: "Log out", action: .logout)
        
        // Version
        let version = MainMenuStaticDataViewModel(text: versionData())
        
        return MainMenuSectionViewModel(rows: [appSettings, account, logOut, version])
    }
    
    private func versionData() -> String {
        return "Version: \(versionId())"
//        return "Player: \(framework(identifier: "com.emp.Player"))"
        //        "Exposure: \(framework(identifier: "com.emp.Exposure"))"
        //        "Analytics: \(framework(identifier: "com.emp.Analytics"))"
        //        "Download: \(framework(identifier: "com.emp.Download"))"
        //        "Utilities: \(framework(identifier: "com.emp.Utilities"))"
    }
    
    private func versionId(identifier: String? = nil) -> String {
        if let identifier = identifier, let bundle = Bundle(identifier: identifier) {
            return framework(bundle: bundle)
        }
        else {
            return framework(bundle: Bundle.main)
        }
        
    }
    
    private func framework(bundle: Bundle) -> String {
        guard let bundleInfo = bundle.infoDictionary else { return "?" }
        
        let version = (bundleInfo["CFBundleShortVersionString"] as? String) ?? ""
        guard let build = bundleInfo["CFBundleVersion"] as? String else {
            return version
        }
        return version + "-" + build
    }
    
    
    func logoImageOptions(size: CGSize) -> KingfisherOptionsInfo {
        return [
            .backgroundDecode,
            .cacheMemoryOnly,
//            .processor(CrispResizingImageProcessor(referenceSize: size, mode: .aspectFit))
        ]
    }
}

extension MainMenuViewModel {
    func select(contentAt index: Int) {
        let rows = sections[1].rows
        (0..<rows.count).forEach{
            if let viewModel = rows[$0] as? MainMenuContentViewModel {
                viewModel.isActive = $0 == index
            }
        }
    }
}

extension MainMenuViewModel {
    func logout() {
        Authenticate(environment: environment)
            .logout(sessionToken: sessionToken)
            .request()
            .validate()
            .response{ (exposureResponse: ExposureResponse<AnyJSONType>) in
                if let error = exposureResponse.error {
                    print(error)
                }
        }
    }
}
