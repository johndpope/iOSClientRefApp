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
    var slidingMenuController: SlidingMenuController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "StretchyCarouselHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "stretchyHeader")
//        collectionView.register(UINib(nibName: "StretchyCarouselHeaderView", bundle: nil), forSupplementaryViewOfKind: StretchyCollectionHeaderKind, withReuseIdentifier: "stretchyHeader")
        collectionView.register(UINib(nibName: "CarouselView", bundle: nil), forCellWithReuseIdentifier: "carousel")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = StretchyCarouselHeaderLayout()
        
        layout.delegate = self
        collectionView.collectionViewLayout = layout
        
        setupViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupViewModel() {
//        guard let tabVC = self.tabBarController as? HomeTabBarController else {
//            fatalError("Unable to proceed without homeTabBarController")
//        }
        
//        let carouselGroupId = "fakeCarousels"//tabVC.dynamicCustomerConfig?.carouselGroupId ?? "fakeCarousels"
//
//        viewModel.loadCarousel(group: carouselGroupId) { [weak self] error in
//            print("ReloadData")
//            self?.collectionView.reloadData()
//        }
        
        viewModel.loadFakeCarousel{ [weak self] index, error in
            self?.collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
//            self?.collectionView.reloadItems(at: )
        }
    }
    
    @IBAction func toggleSlidingMenuAction(_ sender: UIBarButtonItem) {
        slidingMenuController?.toggleSlidingMenu()
    }
}

extension CarouselViewController: SlidingMenuDelegate {
    
}


extension CarouselViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(#function,section)
        return viewModel.content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(#function,indexPath.row)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "carousel", for: indexPath) as! CarouselView
        
        let carouselViewModel = viewModel.content[indexPath.row]
        cell.bind(viewModel: carouselViewModel)
        
        return cell
    }
    
}

extension CarouselViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(#function,indexPath.row)
        if let cell = cell as? CarouselView {
            cell.selectedAsset = { [weak self] asset in
                self?.presetDetails(for: asset, from: .other)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let view = view as? StretchyCarouselHeaderView, elementKind == StretchyCollectionHeaderKind {
            view.selectedAsset = { [weak self] asset in
                self?.presetDetails(for: asset, from: .other)
            }
            // Customize
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let bannerViewModel = viewModel.bannerViewModel, kind == UICollectionElementKindSectionHeader {//StretchyCollectionHeaderKind {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "stretchyHeader", for: indexPath) as! StretchyCarouselHeaderView
            view.bind(viewModel: bannerViewModel)
            return view
        }
        return UICollectionReusableView()
    }
}

extension CarouselViewController: StretchyCarouselHeaderLayoutDelegate {
    var usesStretchyHeader: Bool {
        return viewModel.bannerViewModel != nil
    }
    
    var startingStretchyHeaderHeight: CGFloat {
        guard let bannerEditorial = viewModel.bannerViewModel?.editorial as? BannerPromotionEditorial else { return 0 }
        return bannerEditorial.estimatedCellSize(for: collectionView.bounds).height
    }
    
    func cellSize(for indexPath: IndexPath) -> CGSize {
        guard !viewModel.content.isEmpty else { return CGSize.zero }
//        print("CarouselViewController",#function,"\([indexPath.item])",viewModel.content[indexPath.row].editorial.estimatedCellSize(for: collectionView.bounds))
        return viewModel.content[indexPath.row].editorial.estimatedCellSize(for: collectionView.bounds)
    }
    
    var edgeInsets: UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    var itemSpacing: CGFloat {
        return 0
    }
}
extension CarouselViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(#function,indexPath.row,viewModel.content[indexPath.row].editorial.estimatedCellSize(for: collectionView.bounds))

        return viewModel.content[indexPath.row].editorial.estimatedCellSize(for: collectionView.bounds)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let bannerEditorial = viewModel.bannerViewModel?.editorial as? BannerPromotionEditorial else { return CGSize.zero }
        return bannerEditorial.estimatedCellSize(for: collectionView.bounds)
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

extension CarouselViewController: AssetDetailsPresenter {
    var assetDetailsPresenter: UIViewController {
        return self
    }
}
