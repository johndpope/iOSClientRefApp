//
//  MainMenuViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-27.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure
import Kingfisher

protocol DynamicContentCategory {
    var title: String { get }
    var presentation: DynamicContentPresentation { get }
}

enum DynamicContentPresentation {
    case singleCarousel
    case multiCarousel
    case tabbedEpg
}

struct DynamicContentCarousel: DynamicContentCategory {
    let title: String
    let presentation: DynamicContentPresentation
    let contentId: String
}

struct FakeDynamicContentCarousel: DynamicContentCategory {
    let title: String
    let presentation: DynamicContentPresentation
    let content: ContentType
    
    enum ContentType {
        case home
        case channels
        case movies
        case documentaries
        case kids
        case clips
    }
}

class MainMenuViewController: UIViewController {

    enum Action {
        case other(segue: MainMenuViewController.Segue.Other)
        case content(segue: DynamicContentCategory)
        case logout
        case none
    }
    
    enum Segue {
        enum Other: String {
            case myDownloads
        }
    }
    
    var selectedOtherSegue: (Segue.Other) -> Void = { _ in }
    var selectedContentSegue: (DynamicContentCategory) -> Void = { _ in }
    
    @IBOutlet weak var serviceLogo: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoAspectRationConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewWIdthConstraint: NSLayoutConstraint!
    
    var dynamicCustomerConfig: DynamicCustomerConfig?
    var viewModel: MainMenuViewModel!
    
    var brand: Branding.ColorScheme {
        return dynamicCustomerConfig?.colorScheme ?? Branding.ColorScheme.default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        tableView.register(UINib(nibName: "MainMenuStaticDataCell", bundle: nil), forCellReuseIdentifier: MainMenuStaticDataViewModel.reuseIdentifier)
        tableView.register(UINib(nibName: "MainMenuPushNavigationCell", bundle: nil), forCellReuseIdentifier: MainMenuPushNavigationViewModel.reuseIdentifier)
        tableView.register(UINib(nibName: "MainMenuContentCell", bundle: nil), forCellReuseIdentifier: MainMenuContentViewModel.reuseIdentifier)
        
        if let conf = dynamicCustomerConfig {
            process(dynamicCustomerConfig: conf)
        }
        else {
            ApplicationConfig(environment: viewModel.environment)
                .fetchFile(fileName: "main.json") { [weak self] file in
                    if let jsonData = file?.config, let dynamicConfig = DynamicCustomerConfig(json: jsonData) {
                        self?.dynamicCustomerConfig = dynamicConfig
                        self?.process(dynamicCustomerConfig: dynamicConfig)
                    }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        apply(brand: brand)
    }
}

extension MainMenuViewController {
    fileprivate func process(dynamicCustomerConfig: DynamicCustomerConfig) {
        apply(brand: dynamicCustomerConfig.colorScheme)
        viewModel.updateDynamicContent(with: dynamicCustomerConfig)
        tableView.reloadData()
        viewModel.select(contentAt: 0)
        triggerAction(for: viewModel.homeContentViewModel, at: IndexPath(item: 0, section: 1))
        
        if let logoString = dynamicCustomerConfig.logoUrl, let logoUrl = URL(string: logoString) {
            serviceLogo
                .kf
                .setImage(with: logoUrl, options: viewModel.logoImageOptions(size: serviceLogo.bounds.size)) { [weak self] (image, error, _, _) in
                    
            }
        }
        else if let preconf = UserInfo.environment?.businessUnit {
            title = preconf
        }
        else {
            title = "My TV"
        }
    }
}

extension MainMenuViewController: AuthorizedEnvironment {
    func authorize(environment: Environment, sessionToken: SessionToken) {
        viewModel = MainMenuViewModel(environment: environment,
                                      sessionToken: sessionToken)
        viewModel.configure()
    }
    var environment: Environment {
        return viewModel.environment
    }
    
    var sessionToken: SessionToken {
        return viewModel.sessionToken
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
        viewModel.logout()
    }
}

extension MainMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        triggerAction(for: viewModel[indexPath], at: indexPath)
    }
    
    fileprivate func triggerAction(for menuItemType: MainMenuItemType, at indexPath: IndexPath) {
        if let actionable = menuItemType as? MainMenuActionType {
            switch actionable.actionIdentifier {
            case .logout:
                actionLogout()
            case .content(segue: let segue):
                viewModel.select(contentAt: indexPath.row)
                selectedContentSegue(segue)
            case .other(segue: let segue):
                selectedOtherSegue(segue)
            case .none: return
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
        cell.selectionStyle = .none
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

extension MainMenuViewController: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        tableView.backgroundColor = brand.backdrop.primary
        view.backgroundColor = brand.backdrop.primary
    }
}
