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
        
        collectionView.register(UINib(nibName: "StretchyCarouselHeaderView", bundle: nil), forSupplementaryViewOfKind: StretchyCollectionHeaderKind, withReuseIdentifier: "stretchyHeader")
        collectionView.register(UINib(nibName: "CarouselView", bundle: nil), forCellWithReuseIdentifier: "carousel")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = StretchyCarouselHeaderLayout()
        layout.delegate = self
        collectionView.collectionViewLayout = layout
        collectionView.alwaysBounceVertical = true
        
        if let conf = dynamicContentCategory {
            prepare(contentFrom: conf)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    enum ContentType: Equatable {
        case fakeCarousels
        case carouselGroup(groupId: String)
        case movies
        case documentaries
        case kids
        case clips
        
        static func == (lhs: ContentType, rhs: ContentType) -> Bool {
            switch (lhs,rhs) {
            case (.fakeCarousels, .fakeCarousels): return true
            case (.carouselGroup(groupId: let lid), .carouselGroup(groupId: let rid)): return lid == rid
            case (.movies, .movies): return true
            case (.documentaries, .documentaries): return true
            case (.kids, .kids): return true
            case (.clips, .clips): return true
            default: return false
            }
        }
    }
    
    
    var dynamicContentCategory: DynamicContentCategory?
    fileprivate func prepare(contentFrom dynamicContentCategory: DynamicContentCategory) {
        updateNavigationTitle(with: dynamicContentCategory)
        if let contentCarousels = dynamicContentCategory as? DynamicContentCarousel {
            viewModel.loadCarousels(for: contentCarousels.carouselGroupId){ [weak self] error in
//                print("reloadCarousels",self?.collectionView.contentOffset)
                self?.collectionView.reloadData()
                //                self?.collectionView.layoutIfNeeded()
            }
        }
        else if let fakeCarousels = dynamicContentCategory as? FakeDynamicContentCarousel {
            switch fakeCarousels.content {
            case .home:
                viewModel.loadFakeMovieCarousels{ [weak self] error in
                    self?.collectionView.reloadData()
                    //                self?.collectionView.layoutIfNeeded()
                }
            case .movies:
                viewModel.loadFakeMovieCarousels{ [weak self] error in
                    self?.collectionView.reloadData()
                    //                self?.collectionView.layoutIfNeeded()
                }
            case .documentaries:
                viewModel.loadFakeDocumentariesCarousels{ [weak self] error in
                    self?.collectionView.reloadData()
                    //                self?.collectionView.layoutIfNeeded()
                }
            case .kids:
                viewModel.loadFakeKidsCarousels{ [weak self] error in
                    self?.collectionView.reloadData()
                    //                self?.collectionView.layoutIfNeeded()
                }
            case .clips:
                viewModel.loadFakeClipsCarousels{ [weak self] error in
                    print("reloadCarousels",self?.collectionView.contentOffset)
                    self?.collectionView.reloadData()
                    //                self?.collectionView.layoutIfNeeded()
                }
            }
        }
    }
    
    
    
//    func reloadCarousels() {
//        viewModel.reset()
////        collectionView.reloadData()
////        collectionView.layoutIfNeeded()
//
//        updateNavigationTitle(with: contentType)
//        switch contentType {
//        case .fakeCarousels:
//            viewModel.loadFakeMovieCarousels{ [weak self] error in
//                self?.collectionView.reloadData()
////                self?.collectionView.layoutIfNeeded()
//            }
//        case .carouselGroup(groupId: let groupId):
//            viewModel.loadCarousels(for: groupId){ [weak self] error in
//                print("reloadCarousels",self?.collectionView.contentOffset)
//                self?.collectionView.reloadData()
////                self?.collectionView.layoutIfNeeded()
//            }
//        case .movies:
//            viewModel.loadFakeMovieCarousels{ [weak self] error in
//                self?.collectionView.reloadData()
////                self?.collectionView.layoutIfNeeded()
//            }
//        case .documentaries:
//            viewModel.loadFakeDocumentariesCarousels{ [weak self] error in
//                self?.collectionView.reloadData()
////                self?.collectionView.layoutIfNeeded()
//            }
//        case .kids:
//            viewModel.loadFakeKidsCarousels{ [weak self] error in
//                self?.collectionView.reloadData()
////                self?.collectionView.layoutIfNeeded()
//            }
//        case .clips:
//            viewModel.loadFakeClipsCarousels{ [weak self] error in
//                print("reloadCarousels",self?.collectionView.contentOffset)
//                self?.collectionView.reloadData()
////                self?.collectionView.layoutIfNeeded()
//            }
//        }
//    }
    
    private func updateNavigationTitle(with contentCategory: DynamicContentCategory) {
        navigationItem.title = contentCategory.title
    }
    
    
    @IBAction func toggleSlidingMenuAction(_ sender: UIBarButtonItem) {
        slidingMenuController?.toggleSlidingMenu()
    }
}

extension CarouselViewController: SlidingMenuDelegate {
    
}


extension CarouselViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "carousel", for: indexPath) as! CarouselView
        
        let carouselViewModel = viewModel.content[indexPath.row]
        cell.bind(viewModel: carouselViewModel)
        
        return cell
    }
    
}

extension CarouselViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? CarouselView {
            cell.selectedAsset = { [weak self] asset in
                self?.presetDetails(for: asset, from: .other)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let view = view as? StretchyCarouselHeaderView, let bannerViewModel = viewModel.bannerViewModel, elementKind == StretchyCollectionHeaderKind {
            view.bind(viewModel: bannerViewModel)
            view.selectedAsset = { [weak self] asset in
                self?.presetDetails(for: asset, from: .other)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == StretchyCollectionHeaderKind {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "stretchyHeader", for: indexPath) as! StretchyCarouselHeaderView
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
        return viewModel.content[indexPath.row].editorial.estimatedCellSize(for: collectionView.bounds)
    }
    
    var edgeInsets: UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    var itemSpacing: CGFloat {
        return 0
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
