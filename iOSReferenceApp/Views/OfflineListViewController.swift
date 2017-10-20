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
    var viewModel: OfflineListViewModel!
    
    class OfflineListViewModel: AuthorizedEnvironment {
        var environment: Environment
        var sessionToken: SessionToken
        func authorize(environment: Environment, sessionToken: SessionToken) {
            self.environment = environment
            self.sessionToken = sessionToken
        }
        
        init(environment: Environment, sessionToken: SessionToken) {
            self.environment = environment
            self.sessionToken = sessionToken
        }
    }
    
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
    enum Segue: String {
        case segueOfflineListToPlayer = "segueOfflineListToPlayer"
    }
}

extension OfflineListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.segueOfflineListToPlayer.rawValue {
            if let destination = segue.destination as? PlayerViewController, let assetId = sender as? String {
                destination.viewModel = PlayerViewModel(sessionToken: sessionToken,
                                                        environment: environment,
                                                        playRequest: .offline(assetId: assetId))
            }
        }
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
        return content[indexPath.row].preferedCellHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let vm = content[indexPath.row]
            
            ExposureSessionManager
                .shared
                .manager
                .delete(media: vm.offlineAsset)
            
            if let metaData = vm.asset {
                ExposureSessionManager
                    .shared
                    .manager
                    .removeMetaData(for: metaData)
            }
            
            content.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
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
            cell.onPlaySelected = { [weak self] offlineMedia in
                self?.performSegue(withIdentifier: Segue.segueOfflineListToPlayer.rawValue, sender: offlineMedia.assetId)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}



// MARK: - AuthorizedEnvironment
extension OfflineListViewController: AuthorizedEnvironment {
    func authorize(environment: Environment, sessionToken: SessionToken) {
        viewModel = OfflineListViewModel(environment: environment,
                                         sessionToken: sessionToken)
    }
    var environment: Environment {
        return viewModel.environment
    }
    
    var sessionToken: SessionToken {
        return viewModel.sessionToken
    }
}
