//
//  PresetViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-05-30.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure

class PresetViewController: UIViewController {
    var viewModel: PresetViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -15)
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont(name: "Helvetica", size: 12)!,
             //             NSForegroundColorAttributeName: UIColor.white
            ],
            for: UIControlState.normal)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "HorizontalScrollRow", bundle: nil),
                           forCellReuseIdentifier: "HorizontalScrollRow")
        
        tableView.register(UINib(nibName: "AssetPreviewHeaderView", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "AssetPreviewHeaderView")
        
        
        setupViewModel()
        viewModel.fetchMetadata{ [unowned self] error in
            if error == nil {
                self.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PresetViewController: UITableViewDelegate {
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

extension PresetViewController: UITableViewDataSource {
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

extension PresetViewController: AuthorizedEnvironment {
    var environment: Environment {
        return viewModel.environment
    }
    
    var sessionToken: SessionToken {
        return viewModel.sessionToken
    }
}

extension PresetViewController: AssetDetailsPresenter {
    var assetDetailsPresenter: UIViewController {
        return self
    }
}

extension PresetViewController {
    fileprivate func setupViewModel() {
        guard let env = UserInfo.environment else {
            // TODO: Fail gracefully
            fatalError("Unable to proceed without valid environment")
        }
        
        let sampleAssets = EnvironmentConfig
            .sampleAssets(environment: env)
        
        if let credentials = UserInfo.credentials {
            viewModel = PresetViewModel(credentials: credentials,
                                        environment: env,
                                        sampleAssets: sampleAssets)
        }
        else if let sessionToken = UserInfo.sessionToken {
            viewModel = PresetViewModel(sessionToken: sessionToken,
                                        environment: env,
                                        sampleAssets: sampleAssets)
        }
        else {
            // TODO: Fail gracefully
            fatalError("Unable to proceed without valid sessionToken")
        }
    }
}
