//
//  MainMenuViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-27.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure

protocol MainMenuItemType {
    static var reuseIdentifier: String { get }
}

protocol MainMenuActionType {
    var actionIdentifier: MainMenuViewController.Action? { get }
}

class MainMenuContentViewModel: MainMenuItemType {
    static var reuseIdentifier: String {
        return "contentCell"
    }
    
    let title: String
    let actionIdentifier: MainMenuViewController.Action?
    var isActive: Bool
    var textColor: UIColor {
        return isActive ? UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1) : UIColor.lightGray
    }
    
    init(title: String, active: Bool = false, action: MainMenuViewController.Action? = nil) {
        self.title = title
        self.isActive = active
        self.actionIdentifier = action
    }
}

class MainMenuStaticDataViewModel: MainMenuItemType {
    static var reuseIdentifier: String {
        return "staticDataCell"
    }
    
    let text: String
    var textColor: UIColor {
        return UIColor.lightGray
    }
    
    init(text: String) {
        self.text = text
    }
}

class MainMenuPushNavigationViewModel: MainMenuItemType, MainMenuActionType {
    
    
    static var reuseIdentifier: String {
        return "pushNavigationCell"
    }
    
    let actionIdentifier: MainMenuViewController.Action?
    
    let title: String
    let image: UIImage?
    
    var textColor: UIColor {
        return UIColor.lightGray
    }
    
    init(title: String, image: UIImage? = nil, action: MainMenuViewController.Action? = nil) {
        self.title = title
        self.image = image
        self.actionIdentifier = action
    }
}

struct MainMenuSectionViewModel {
    let rows: [MainMenuItemType]
    
    let backgroundColor: UIColor = UIColor(red: 0.047, green: 0.055, blue: 0.059, alpha: 1)
    let height: CGFloat = 3
    
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
    
    
    subscript(indexPath: IndexPath) -> MainMenuItemType {
        get {
            return sections[indexPath.section].rows[indexPath.row]
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
    
}

extension MainMenuViewModel {
    func logout(environment: Environment, sessionToken: SessionToken) {
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

class MainMenuViewController: UIViewController {

    enum Action {
        case other(segue: MainMenuViewController.Segue.Other)
        case content(segue: MainMenuViewController.Segue.Content)
        case logout
    }
    
    enum Segue {
        enum Other: String {
            case myDownloads
        }
        enum Content: String {
            case home
        }
    }
    
    var selectedOtherSegue: (Segue.Other) -> Void = { _ in }
    var selectedContentSegue: (Segue.Content) -> Void = { _ in }
    
    @IBOutlet weak var serviceLogo: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewWIdthConstraint: NSLayoutConstraint!
    
    var viewModel: MainMenuViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        tableView.register(UINib(nibName: "MainMenuStaticDataCell", bundle: nil), forCellReuseIdentifier: MainMenuStaticDataViewModel.reuseIdentifier)
        tableView.register(UINib(nibName: "MainMenuPushNavigationCell", bundle: nil), forCellReuseIdentifier: MainMenuPushNavigationViewModel.reuseIdentifier)
        tableView.register(UINib(nibName: "MainMenuContentCell", bundle: nil), forCellReuseIdentifier: MainMenuContentViewModel.reuseIdentifier)

        let activeContentIndex = 0 // TODO: Fetch from where?
        viewModel = MainMenuViewModel()
        viewModel.configure(activeContentIndex: activeContentIndex)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MainMenuViewController {
    func constrain(width: CGFloat) {
        logoWidthConstraint.constant = width
        tableViewWIdthConstraint.constant = width
        view.layoutIfNeeded()
    }
}

extension MainMenuViewController {
    func actionLogout() {
        defer {
            UserInfo.clear()
            navigationController?.popViewController(animated: true)
        }
        guard let sessionToken = UserInfo.sessionToken, let environment = UserInfo.environment else {
            return
        }
        viewModel.logout(environment: environment,
                         sessionToken: sessionToken)
    }
}

extension MainMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let actionable = viewModel[indexPath] as? MainMenuActionType, let action = actionable.actionIdentifier {
            switch action {
            case .logout:
                actionLogout()
            case .content(segue: let segue):
                fatalError("Replace content view controller!")
                return
            case .other(segue: let segue):
                selectedOtherSegue(segue)
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel[section].height
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = viewModel[section].backgroundColor
    }
}


extension MainMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return  viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel[section].rows.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView() // TODO: Reusable view?
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = viewModel[indexPath.section].rows[indexPath.row]
        return tableView.dequeueReusableCell(withIdentifier: type(of: vm).reuseIdentifier, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let vm = viewModel[indexPath.section].rows[indexPath.row]
        if let vm = vm as? MainMenuContentViewModel, let cell = cell as? MainMenuContentCell {
            cell.bind(viewModel: vm)
        }
        else if let vm = vm as? MainMenuPushNavigationViewModel, let cell = cell as? MainMenuPushNavigationCell {
            cell.bind(viewModel: vm)
        }
        else if let vm = vm as? MainMenuStaticDataViewModel, let cell = cell as? MainMenuStaticDataCell {
            cell.bind(viewModel: vm)
        }
    }
}
