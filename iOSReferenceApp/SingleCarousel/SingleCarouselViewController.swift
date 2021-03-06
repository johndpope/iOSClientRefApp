//
//  SingleCarouselViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-22.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure
import Kingfisher
import GoogleCast

class SingleCarouselViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: SingleCarouselViewModel!
    var slidingMenuController: SlidingMenuController?
    
    var brand: Branding.ColorScheme = Branding.ColorScheme.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "AssetPreviewCell", bundle: nil), forCellWithReuseIdentifier: "AssetPreviewCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 2*viewModel.preferredCellSpacing
        flowLayout.minimumLineSpacing = 0
        collectionView.contentInset = viewModel.edgeInsets
//        collectionView.isPagingEnabled = true
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
        }
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apply(brand: brand)
    }
    
    func bind(viewModel: SingleCarouselViewModel) {
        self.viewModel = viewModel
        self.collectionView.reloadData()
    }
    
    var dynamicContentCategory: DynamicContentCategory?
    fileprivate func prepare(contentFrom dynamicContentCategory: DynamicContentCategory) {
        updateNavigationTitle(with: dynamicContentCategory)
        if let contentCarousel = dynamicContentCategory as? DynamicContentCarousel {
            viewModel.loadCarousel(for: contentCarousel.contentId){ [weak self] error in
                self?.collectionView.reloadData()
            }
        }
        else if let fakeCarousel = dynamicContentCategory as? FakeDynamicContentCarousel {
            switch fakeCarousel.content {
            case .home:
                viewModel.loadFakeMovieCarousel{ [weak self] error in
                    self?.collectionView.reloadData()
                }
            case .movies:
                viewModel.loadFakeMovieCarousel{ [weak self] error in
                    self?.collectionView.reloadData()
                }
            case .documentaries:
                viewModel.loadFakeDocumentariesCarousel{ [weak self] error in
                    self?.collectionView.reloadData()
                }
            case .kids:
                viewModel.loadFakeKidsCarousel{ [weak self] error in
                    self?.collectionView.reloadData()
                }
            case .clips:
                viewModel.loadFakeClipsCarousel{ [weak self] error in
                    self?.collectionView.reloadData()
                }
            case .channels:
                print(#function,"Dont display EPG in single carousel")
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

extension SingleCarouselViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToSearch" {
            if let destination = segue.destination as? SearchViewController {
                destination.authorize(environment: environment,
                                      sessionToken: sessionToken)
            }
        }
        else if segue.identifier == "segueListToDetails" {
            if let destination = segue.destination as? AssetDetailsViewController {
                destination.bind(viewModel: AssetDetailsViewModel(asset: sender as! Asset,
                                                         environment: environment,
                                                         sessionToken: sessionToken))
                destination.bind(downloadViewModel: DownloadAssetViewModel(environment: environment,
                                                                  sessionToken: sessionToken))
                destination.brand = brand
                destination.presentedFrom = .other
            }
        }
    }
}


extension SingleCarouselViewController: SlidingMenuDelegate {
    
}


extension SingleCarouselViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "AssetPreviewCell", for: indexPath) as! AssetPreviewCell
    }
    
}

extension SingleCarouselViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        preloadNextBatch(after: indexPath)
        if let preview = cell as? AssetPreviewCell {
            let vm = viewModel.content[indexPath.row]
            
            preview.reset()
            preview.thumbnail(title: vm.anyTitle(locale: "en"))
            preview.apply(brand: brand)
            
            // We need aspectFit for "general" thumbnail since we have little control over screen size.
            preview.thumbnailView.contentMode = .scaleAspectFit
            if let url = viewModel.imageUrl(for: indexPath) {
                preview
                    .thumbnailView
                    .kf
                    .setImage(with: url, options: viewModel.thumbnailImageOptions(for: collectionView.bounds.width)) { (image, error, cache, url) in
                        // AspectFill for images to make sure they "fill" the entire preview.
                        preview.thumbnailView.contentMode = .scaleAspectFill
                        if let error = error {
                            print("Kingfisher: ",error)
                        }
                }
            }
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
//        if let view = view as? CarouselFooterView, elementKind == UICollectionElementKindSectionFooter {
//            view.setupFade()
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if kind == UICollectionElementKindSectionFooter {
//            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "carouselFooter", for: indexPath) as! CarouselFooterView
//        }
//        return UICollectionReusableView()
//    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = viewModel.content[indexPath.row].asset
        performSegue(withIdentifier: "segueListToDetails", sender: asset)
    }
}

extension SingleCarouselViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.preferredCellSize(forWidth: collectionView.bounds.size.width)
    }
}

extension SingleCarouselViewController: AuthorizedEnvironment {
    func authorize(environment: Environment, sessionToken: SessionToken) {
        viewModel = SingleCarouselViewModel(environment: environment,
                                            sessionToken: sessionToken)
    }
    
    var environment: Environment {
        return viewModel.environment
    }
    
    var sessionToken: SessionToken {
        return viewModel.sessionToken
    }
    
}

extension SingleCarouselViewController: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.flatMap{ viewModel.imageUrl(for: $0) }
        ImagePrefetcher(urls: urls).start()
    }
}

extension SingleCarouselViewController {
    func batch(for indexPath: IndexPath) -> Int {
        return  1 + indexPath.row / 50
    }
    
    fileprivate func preloadNextBatch(after indexPath: IndexPath) {
        //let currentBatch = batch(for: indexPath)
        //        viewModel.fetchMetadata(batch: currentBatch+1) { [unowned self] (batch, error) in
        //            if let error = error {
        //                print(error)
        //            }
        //            else if batch == currentBatch {
        //                self.collectionView.reloadData()
        //            }
        //        }
    }
}

extension SingleCarouselViewController: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        collectionView.backgroundColor = brand.backdrop.primary
        view.backgroundColor = brand.backdrop.primary
    }
}
