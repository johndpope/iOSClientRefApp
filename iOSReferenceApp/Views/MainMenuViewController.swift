//
//  MainMenuViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-27.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

protocol MainMenuItemType {
    var title: String { get }
}

class MainMenuContentViewModel: MainMenuItemType {
    let title: String
    var isActive: Bool
    
    init(title: String, active: Bool = false) {
        self.title = title
        self.isActive = active
    }
}

class MainMenuVersionViewModel: MainMenuItemType {
    let title: String
    
    init(title: String) {
        self.title = title
    }
}

class MainMenuPushNavigationViewModel: MainMenuItemType {
    let title: String
    let imageUrl: URL?
    
    init(title: String, imageUrl: URL? = nil) {
        self.title = title
        self.imageUrl = imageUrl
    }
}

struct MainMenuSectionViewModel {
    let rows: [MainMenuItemType]
    
    subscript(index: Int) -> MainMenuItemType {
        get {
            return rows[index]
        }
    }
}

class MainMenuViewModel {
    var sections: [MainMenuSectionViewModel] = []
    
    subscript(index: Int) -> MainMenuSectionViewModel {
        get {
            return sections[index]
        }
    }
    
    init() {
        
    }
    
    func configure(activeContentIndex index: Int) {
        let userPrefs = configureUserPreferences()
        let contentList = configureContentLists(activeIndex: index)
        let appSettings = configureAppSettings()
        
        sections = [userPrefs, contentList, appSettings]
    }
    
    private func configureUserPreferences() -> MainMenuSectionViewModel {
        let download = MainMenuPushNavigationViewModel(title: "My downloads")
        let favourites = MainMenuPushNavigationViewModel(title: "Favourites")
        return MainMenuSectionViewModel(rows: [download, favourites])
    }
    
    private func configureContentLists(activeIndex index: Int) -> MainMenuSectionViewModel {
        let home = MainMenuContentViewModel(title: "Home")
        let section = [home]
        
        section[index].isActive = true
        
        return MainMenuSectionViewModel(rows: section)
    }
    
    private func configureAppSettings() -> MainMenuSectionViewModel {
        let appSettings = MainMenuPushNavigationViewModel(title: "App Settings")
        let account = MainMenuPushNavigationViewModel(title: "Account")
        let logOut = MainMenuPushNavigationViewModel(title: "Log out")
        
        return MainMenuSectionViewModel(rows: [appSettings, account, logOut])
    }
}

class MainMenuViewController: UIViewController {

    @IBOutlet weak var serviceLogo: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: MainMenuViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let activeContentIndex = 0 // TODO: Fetch from where?
        viewModel = MainMenuViewModel()
        viewModel.configure(activeContentIndex: activeContentIndex)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MainMenuViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return viewModel?.headerHeight(index: section) ?? 0
//    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return viewModel[indexPath.section][indexPath.row]
//    }
}


extension MainMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return  viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "HorizontalScrollRow") as! HorizontalScrollRow
//        guard let carousel = viewModel?.carousels[indexPath.section] else { fatalError("No carousels") }
//        cell.bind(viewModel: carousel)
//        cell.cellSelected = { [weak self] asset in
//            self?.presetDetails(for: asset, from: .other)
//        }
//
//        return cell
    }
}
