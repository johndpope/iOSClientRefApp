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
    
    var sections: [MainMenuSectionViewModel] = []
    var dynamicCustomerConfig: DynamicCustomerConfig?
    
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
    
    init(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
    
    func configure(activeContentIndex index: Int) {
        let userPrefs = configureUserPreferences()
        let contentList = configureContentLists(activeIndex: index)
        let appSettings = configureAppSettings()
        
        sections = [userPrefs, contentList, appSettings]
    }
    
    private func configureUserPreferences() -> MainMenuSectionViewModel {
        let download = MainMenuPushNavigationViewModel(title: "My downloads", image: #imageLiteral(resourceName: "download"), action: .other(segue: .myDownloads))
        let favourites = MainMenuPushNavigationViewModel(title: "Favourites", image: #imageLiteral(resourceName: "download-list"))
        return MainMenuSectionViewModel(rows: [download, favourites])
    }
    
    private func configureContentLists(activeIndex index: Int) -> MainMenuSectionViewModel {
        let home = MainMenuContentViewModel(title: "Home", action: .content(segue: .home))
        let section = [home]
        
        section[index].isActive = true
        
        return MainMenuSectionViewModel(rows: section)
    }
    
    private func configureAppSettings() -> MainMenuSectionViewModel {
        let appSettings = MainMenuPushNavigationViewModel(title: "App Settings")
        let account = MainMenuPushNavigationViewModel(title: "Account")
        let logOut = MainMenuPushNavigationViewModel(title: "Log out", action: .logout)
        
        // Version
        let version = MainMenuStaticDataViewModel(text: versionData())
        
        return MainMenuSectionViewModel(rows: [appSettings, account, logOut, version])
    }
    
    private func versionData() -> String {
        return "Player: \(framework(identifier: "com.emp.Player"))"
        //        "Exposure: \(framework(identifier: "com.emp.Exposure"))"
        //        "Analytics: \(framework(identifier: "com.emp.Analytics"))"
        //        "Download: \(framework(identifier: "com.emp.Download"))"
        //        "Utilities: \(framework(identifier: "com.emp.Utilities"))"
    }
    
    private func framework(identifier: String) -> String {
        guard let bundleInfo = Bundle(identifier: identifier)?.infoDictionary else { return "?" }
        
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
            .processor(CrispResizingImageProcessor(referenceSize: size, mode: .aspectFit))
        ]
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