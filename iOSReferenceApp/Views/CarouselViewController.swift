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
        
        collectionView.register(UINib(nibName: "CarouselView", bundle: nil), forCellWithReuseIdentifier: "carousel")
        
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
            self?.collectionView.invalidateIntrinsicContentSize()
            self?.collectionView.reloadData()
        }
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
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("CarouselViewController",#function)
        if let cell = cell as? CarouselView {
            let carouselViewModel = viewModel.content[indexPath.row]
            cell.bind(viewModel: carouselViewModel)
        }
//        cell.cellSelected = { [weak self] asset in
//            self?.presetDetails(for: asset, from: .other)
//        }
    }
}

extension CarouselViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.content[indexPath.row].layout.carouselCellSize(for: collectionView.bounds)
    }
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
