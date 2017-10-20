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
    var isTransitioningBackground: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "HorizontalScrollRow", bundle: nil),
                           forCellReuseIdentifier: "HorizontalScrollRow")
        
        tableView.register(UINib(nibName: "AssetPreviewHeaderView", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "AssetPreviewHeaderView")
        
        
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let searchImage = #imageLiteral(resourceName: "nav-search").withRenderingMode(.alwaysOriginal)
        let searchButton = UIBarButtonItem(image: searchImage, landscapeImagePhone: searchImage, style: .plain, target: self, action: #selector(VODViewController.searchAction))
        
        tabBarController?.navigationItem.rightBarButtonItems = [searchButton]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.navigationItem.rightBarButtonItems = nil
    }
    
    enum Segue: String {
        case segueVodToSearch = "segueVodToSearch"
    }
    func searchAction() {
        performSegue(withIdentifier: Segue.segueVodToSearch.rawValue, sender: nil)
    }
}

extension VODViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "AssetPreviewHeaderView")
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? AssetPreviewHeaderView {
            header.titleLabel.text = viewModel?.getSectionTitle(atIndex: section)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel?.headerHeight(index: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel?.rowHeight(index: indexPath.section) ?? 0
    }
}

extension VODViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.carousels.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HorizontalScrollRow") as! HorizontalScrollRow
        guard let carousel = viewModel?.carousels[indexPath.section] else { fatalError("No carousels") }
        cell.bind(viewModel: carousel)
        cell.cellSelected = { [weak self] asset in
            self?.presetDetails(for: asset, from: .other)
        }
        cell.didScrollLoadImage = { [weak self] image in
            self?.transitionBackground(to: image)
        }
        
        return cell
    }
}

extension VODViewController {
    func transitionBackground(to image: UIImage) {
        if !isTransitioningBackground {
            isTransitioningBackground = true
            UIView.transition(with: backgroundView,
                              duration:0.5,
                              options: .transitionCrossDissolve,
                              animations: { self.backgroundView.image = image }) { [weak self] completed in
                                self?.isTransitioningBackground = false
            }
        }
    }
}

extension VODViewController: AssetDetailsPresenter {
    var assetDetailsPresenter: UIViewController {
        return self
    }

    func authorize(environment: Environment, sessionToken: SessionToken) {
        viewModel = VODViewModel(environment: environment,
                                 sessionToken: sessionToken)
    }
    var environment: Environment {
        return viewModel.environment
    }
    
    var sessionToken: SessionToken {
        return viewModel.sessionToken
    }
}

extension VODViewController {
    fileprivate func setupViewModel() {
        guard let tabVC = self.tabBarController as? HomeTabBarController else {
            fatalError("Unable to proceed without homeTabBarController")
        }
        
        let carouselGroupId = tabVC.dynamicCustomerConfig?.carouselGroupId ?? "fakeCarousels"
        
        viewModel.loadCarousel(group: carouselGroupId) { [weak self] error in
            self?.tableView.reloadData()
        }
    }
}

extension VODViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SearchViewController, segue.identifier == Segue.segueVodToSearch.rawValue {
            destination.viewModel = SearchViewModel(environment: viewModel.environment,
                                                    sessionToken: viewModel.sessionToken)
        }
    }
}
