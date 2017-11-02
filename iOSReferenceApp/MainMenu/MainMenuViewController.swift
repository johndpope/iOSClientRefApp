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
}

struct DynamicContentCarousel: DynamicContentCategory {
    let title: String
    let carouselGroupId: String
}

struct FakeDynamicContentCarousel: DynamicContentCategory {
    let title: String
    let content: ContentType
    
    enum ContentType {
        case home
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
    
    var viewModel: MainMenuViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        tableView.register(UINib(nibName: "MainMenuStaticDataCell", bundle: nil), forCellReuseIdentifier: MainMenuStaticDataViewModel.reuseIdentifier)
        tableView.register(UINib(nibName: "MainMenuPushNavigationCell", bundle: nil), forCellReuseIdentifier: MainMenuPushNavigationViewModel.reuseIdentifier)
        tableView.register(UINib(nibName: "MainMenuContentCell", bundle: nil), forCellReuseIdentifier: MainMenuContentViewModel.reuseIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func apply(dynamicConfig: DynamicCustomerConfig) {
        viewModel.updateDynamicContent(with: dynamicConfig)
        if let logoString = dynamicConfig.logoUrl, let logoUrl = URL(string: logoString) {
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
        if let actionable = viewModel[indexPath] as? MainMenuActionType {
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
