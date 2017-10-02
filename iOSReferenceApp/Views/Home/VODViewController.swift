//
//  PresetViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-05-30.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure

class VODViewController: UIViewController {
    var viewModel: VODViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "HorizontalScrollRow", bundle: nil),
                           forCellReuseIdentifier: "HorizontalScrollRow")
        
        tableView.register(UINib(nibName: "AssetPreviewHeaderView", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "AssetPreviewHeaderView")
        
        
        setupViewModel()
    }
}

extension VODViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "AssetPreviewHeaderView")
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? AssetPreviewHeaderView {
            
            header.titleLabel.text = viewModel.categories[section].title
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.headerHeight(index: section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.rowHeight(index: indexPath.section)
    }
}

extension VODViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HorizontalScrollRow") as! HorizontalScrollRow
        cell.bind(viewModel: viewModel.categories[indexPath.section])
        cell.cellSelected = { [unowned self] asset in
            self.presetDetails(for: asset)
        }
        
        return cell
    }
}

extension VODViewController: AuthorizedEnvironment {
    var environment: Environment {
        return viewModel.environment
    }
    
    var sessionToken: SessionToken {
        return viewModel.sessionToken
    }
}

extension VODViewController: AssetDetailsPresenter {
    var assetDetailsPresenter: UIViewController {
        return self
    }
}

extension VODViewController {
    fileprivate func setupViewModel() {
        guard let env = UserInfo.environment else {
            // TODO: Fail gracefully
            fatalError("Unable to proceed without valid environment")
        }
        
        if let credentials = UserInfo.credentials {
            viewModel = VODViewModel(credentials: credentials,
                                     environment: env)
        }
        else if let sessionToken = UserInfo.sessionToken {
            viewModel = VODViewModel(sessionToken: sessionToken,
                                     environment: env)
        }
        else {
            // TODO: Fail gracefully
            fatalError("Unable to proceed without valid sessionToken")
        }

        viewModel.loadCategories { [unowned self] (section, error) in
            guard let section = section else { return }
            self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
    }
}
