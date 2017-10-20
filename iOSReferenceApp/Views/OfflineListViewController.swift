//
//  OfflineListViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-19.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import UIKit
import Exposure

class OfflineListViewController: UIViewController {
    
    fileprivate var content: [OfflineListCellViewModel] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    var onDismissedWithSelection: (OfflineMediaAsset?) -> Void = { _ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "OfflineListCell", bundle: nil),
                           forCellReuseIdentifier: "offlineListCell")
        content = ExposureSessionManager
            .shared
            .manager
            .offlineAssetsWithMetaData()
            .map{ OfflineListCellViewModel(offlineAsset: $0.0, metaData: $0.1) }
    }
    
    @IBAction func unwindListAction(_ sender: UIBarButtonItem) {
        unwind(with: nil)
    }
}

extension OfflineListViewController {
    func unwind(with offlineMediaAsset: OfflineMediaAsset?) {
        
        onDismissedWithSelection(offlineMediaAsset)
        navigationController?.dismiss(animated: true)
    }
}

extension OfflineListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return content[indexPath.row].preferedHeight
    }
}

extension OfflineListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "offlineListCell", for: indexPath) as! OfflineListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? OfflineListCell {
            cell.bind(viewModel: content[indexPath.row])
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
