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

class OfflineListViewController: UIViewController, AssetDetailsPresenter {
    var assetDetailsPresenter: UIViewController { return self }
    
    var slidingMenuController: SlidingMenuController?
    var viewModel: OfflineListViewModel!
    
    fileprivate var content: [OfflineListCellViewModel] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    var brand: Branding.ColorScheme = Branding.ColorScheme.default
    
    var presentedFrom: PresentedFrom = .other
    enum PresentedFrom {
        case assetDetails(onSelected: (OfflineMediaAsset, Asset?) -> Void)
        case other
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "OfflineListCell", bundle: nil),
                           forCellReuseIdentifier: "offlineListCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        content = viewModel.fetchContent()
        
        apply(brand: brand)
        navigationController?.apply(brand: brand)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    
    
    @IBAction func toggleSlidingMenuAction(_ sender: UIBarButtonItem) {
        slidingMenuController?.toggleSlidingMenu()
    }
}

extension OfflineListViewController {
    enum Segue: String {
        case segueOfflineListToPlayer = "segueOfflineListToPlayer"
        case segueOfflineListToDetails = "segueOfflineListToDetails"
    }
}

extension OfflineListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.segueOfflineListToPlayer.rawValue {
            if let destination = segue.destination as? PlayerViewController, let assetId = sender as? String {
                destination.viewModel = PlayerViewModel(sessionToken: sessionToken,
                                                        environment: environment,
                                                        playRequest: .offline(assetId: assetId, metaData: nil))
                destination.brand = brand
            }
        }
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vm = content[indexPath.row]
        switch presentedFrom {
        case .assetDetails(onSelected: let callback):
            callback(vm.offlineAsset, vm.asset)
            
            // This should be called ONLY when the list was presented modaly inside a navController, typically by a "back" button in the navBar (which wont be visible otherwise)
            navigationController?.popViewController(animated: true)
        case .other:
            guard let asset = vm.asset else { return }
            presetDetails(for: asset, from: .offlineList, with: brand)
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
            cell.apply(brand: brand)
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

extension OfflineListViewController: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        tableView.backgroundColor = brand.backdrop.primary
        view.backgroundColor = brand.backdrop.primary
    }
}
