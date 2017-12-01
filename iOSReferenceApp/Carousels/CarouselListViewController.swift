//
//  CarouselListViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-03.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure
import GoogleCast

class CarouselListViewController: UIViewController {
    
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
        
        let castButton = GCKUICastButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0),
                                                       width: CGFloat(24), height: CGFloat(24)))
        castButton.apply(brand: brand)
        var navItems = navigationItem.rightBarButtonItems
        navItems?.append(UIBarButtonItem(customView: castButton))
        navigationItem.rightBarButtonItems = navItems
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apply(brand: brand)
    }
    
    var brand: Branding.ColorScheme = Branding.ColorScheme.default
    
    var dynamicContentCategory: DynamicContentCategory?
    fileprivate func prepare(contentFrom dynamicContentCategory: DynamicContentCategory) {
        updateNavigationTitle(with: dynamicContentCategory)
        if let contentCarousels = dynamicContentCategory as? DynamicContentCarousel {
            viewModel.loadCarousels(for: contentCarousels.contentId){ [weak self] error in
                self?.collectionView.reloadData()
            }
        }
        else if let fakeCarousels = dynamicContentCategory as? FakeDynamicContentCarousel {
            switch fakeCarousels.content {
            case .home:
                viewModel.loadFakeMovieCarousels{ [weak self] error in
                    self?.collectionView.reloadData()
                }
            case .movies:
                viewModel.loadFakeMovieCarousels{ [weak self] error in
                    self?.collectionView.reloadData()
                }
            case .documentaries:
                viewModel.loadFakeDocumentariesCarousels{ [weak self] error in
                    self?.collectionView.reloadData()
                }
            case .kids:
                viewModel.loadFakeKidsCarousels{ [weak self] error in
                    self?.collectionView.reloadData()
                }
            case .clips:
                viewModel.loadFakeClipsCarousels{ [weak self] error in
                    self?.collectionView.reloadData()
                }
            case .channels:
                print(#function,"Dont display EPG in carousels")
                return
            }
        }
    }
    
    private func updateNavigationTitle(with contentCategory: DynamicContentCategory) {
        navigationItem.title = contentCategory.title
    }
    
    
    @IBAction func toggleSlidingMenuAction(_ sender: UIBarButtonItem) {
        slidingMenuController?.toggleSlidingMenu()
    }
}


extension CarouselListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToSearch" {
            if let destination = segue.destination as? SearchViewController {
                destination.authorize(environment: environment,
                                      sessionToken: sessionToken)
            }
        }
    }
}
extension CarouselListViewController: SlidingMenuDelegate {
    
}


extension CarouselListViewController: UICollectionViewDataSource {
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

extension CarouselListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? CarouselView {
            cell.brand = brand
            cell.apply(brand: brand)
            cell.selectedAsset = { [weak self] asset in
                guard let `self` = self else { return }
                `self`.presetDetails(for: asset, from: .other, with: `self`.brand)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let view = view as? StretchyCarouselHeaderView, let bannerViewModel = viewModel.bannerViewModel, elementKind == StretchyCollectionHeaderKind {
            view.brand = brand
            view.bind(viewModel: bannerViewModel)
            view.apply(brand: brand)
            view.selectedAsset = { [weak self] asset in
                guard let `self` = self else { return }
                `self`.presetDetails(for: asset, from: .other, with: `self`.brand)
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

extension CarouselListViewController: StretchyCarouselHeaderLayoutDelegate {
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

extension CarouselListViewController: AuthorizedEnvironment {
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

extension CarouselListViewController: AssetDetailsPresenter {
    var assetDetailsPresenter: UIViewController {
        return self
    }
}

extension CarouselListViewController: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        collectionView.backgroundColor = brand.backdrop.primary
        view.backgroundColor = brand.backdrop.primary
    }
}
