//
//  CarouselViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-22.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure

class CarouselViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: CarouselListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.register(UINib(nibName: "CarouselView", bundle: nil), forCellReuseIdentifier: "carousel")
        
        collectionView.register(UINib(nibName: "CarouselView", bundle: nil), forCellWithReuseIdentifier: "carousel")
        
        
//        let layout = UICollectionViewFlowLayout()
//        collectionView
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setupViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupViewModel() {
        guard let tabVC = self.tabBarController as? HomeTabBarController else {
            fatalError("Unable to proceed without homeTabBarController")
        }
        
        let carouselGroupId = "fakeCarousels"//tabVC.dynamicCustomerConfig?.carouselGroupId ?? "fakeCarousels"
        
        viewModel.loadCarousel(group: carouselGroupId) { [weak self] error in
//            self?.tableView.reloadData()
            self?.collectionView.reloadData()
        }
    }
}

extension CarouselViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.content.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "carousel", for: indexPath) //as! CarouselView
    }
}

extension CarouselViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print(#function, indexPath.row, indexPath.section)
        return 308
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        print(#function, indexPath.row, indexPath.section)
        return 308
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print(#function, indexPath.row, indexPath.section)
//        if let cell = cell as? CarouselView {
//            let carouselViewModel = viewModel.content[indexPath.row]
//            cell.bind(viewModel: carouselViewModel)
//        }
        //        cell.cellSelected = { [weak self] asset in
        //            self?.presetDetails(for: asset, from: .other)
        //        }
        
    }
}

extension CarouselViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "carousel", for: indexPath)
    }
}

extension CarouselViewController: UICollectionViewDelegate {
    
}

extension CarouselViewController: AuthorizedEnvironment {
    func authorize(environment: Environment, sessionToken: SessionToken) {
        viewModel = CarouselListViewModel(environment: environment,
                                          sessionToken: sessionToken)
    }
    var environment: Environment {
        return viewModel.environment
    }
    
    var sessionToken: SessionToken {
        return viewModel.sessionToken
    }
}
