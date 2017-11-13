//
//  LiveListViewController.swift
//  iOSReferenceApp
//
//  Created by Hui Wang on 2017-05-29.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure

class LiveListViewController: UIViewController {
    var viewModel: LiveListViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "HorizontalScrollRow", bundle: nil),
                           forCellReuseIdentifier: "HorizontalScrollRow")
        
        tableView.register(UINib(nibName: "AssetPreviewHeaderView", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "AssetPreviewHeaderView")
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension LiveListViewController: UITableViewDelegate {
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

extension LiveListViewController: UITableViewDataSource {
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
            self.presetDetails(for: asset, from: .other)
        }
        
        return cell
    }
}

extension LiveListViewController: AuthorizedEnvironment {
    func authorize(environment: Environment, sessionToken: SessionToken) {
        viewModel = LiveListViewModel(sessionToken: sessionToken,
                                      environment: environment)
    }
    var environment: Environment {
        return viewModel.environment
    }
    
    var sessionToken: SessionToken {
        return viewModel.sessionToken
    }
}

extension LiveListViewController: AssetDetailsPresenter {
    var assetDetailsPresenter: UIViewController {
        return self
    }
}

extension LiveListViewController {
    fileprivate func setupViewModel() {
        // Load rows
        viewModel.loadCategories{ [unowned self] section, error in
            if let section = section {
                self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
            }
        }
        
    }
}
