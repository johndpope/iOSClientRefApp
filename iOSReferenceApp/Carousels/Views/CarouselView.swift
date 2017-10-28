//
//  CarouselView.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-22.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure
import Kingfisher

class CarouselView: UICollectionViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    var selectedAsset: (Asset) -> Void = { _ in }
    
    fileprivate(set) var viewModel: CarouselViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(UINib(nibName: "HeroPromotionCell", bundle: nil), forCellWithReuseIdentifier: "heroCell")
        collectionView.register(UINib(nibName: "PortraitTrioPromotionCell", bundle: nil), forCellWithReuseIdentifier: "portraitTrioCell")
        collectionView.register(UINib(nibName: "PortraitPromotionCell", bundle: nil), forCellWithReuseIdentifier: "portraitCell")

        collectionView.register(UINib(nibName: "CarouselHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "carouselHeader")
        
        collectionView.register(UINib(nibName: "CarouselFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "carouselFooter")

        collectionView.delegate = self
        collectionView.dataSource = self
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
        }
        
    }
    
    func bind(viewModel: CarouselViewModel, environment: Environment, sessionToken: SessionToken) {
        print(#function)
        self.viewModel = viewModel
        collectionView.collectionViewLayout = viewModel.editorial.layout
    }
    
}



extension CarouselView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.editorial.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.editorial is HeroPromotionEditorial {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "heroCell", for: indexPath) as! HeroPromotionCell
        }
        else if viewModel.editorial is PortraitTrioPromotionEditorial {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "portraitTrioCell", for: indexPath) as! PortraitTrioPromotionCell
        }
        else if viewModel.editorial is PortraitPromotionEditorial {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "portraitCell", for: indexPath) as! PortraitPromotionCell
        }
        return UICollectionViewCell()
    }
}

extension CarouselView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        preloadNextBatch(after: indexPath)
        if let cell = cell as? HeroPromotionCell {
            cell.configure(with: viewModel.editorial as? HeroPromotionEditorial,
                           for: indexPath.row)
            cell.selectedAsset = { [weak self] asset in
                self?.selectedAsset(asset)
            }
        }
        else if let cell = cell as? PortraitTrioPromotionCell {
            cell.configure(with: viewModel.editorial as? PortraitTrioPromotionEditorial,
                           for: indexPath.row)
            cell.selectedAsset = { [weak self]  asset in
                self?.selectedAsset(asset)
            }
        }
        else if let cell = cell as? PortraitPromotionCell {
            cell.configure(with: viewModel.editorial as? PortraitPromotionEditorial,
                           for: indexPath.row)
            cell.selectedAsset = { [weak self]  asset in
                self?.selectedAsset(asset)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "carouselHeader", for: indexPath) as! CarouselHeaderView
            view.configure(with: viewModel.editorial)
            return view
        }
        
        if kind == UICollectionElementKindSectionFooter {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "carouselFooter", for: indexPath) as! CarouselFooterView
            view.setupFade()
            return view
        }
        return UICollectionReusableView()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print(#function)
    }
}


extension CarouselView: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = viewModel.editorial.content.flatMap{ $0.prefetchImageUrls() }
        ImagePrefetcher(urls: urls).start()
    }
}

extension CarouselView {
    func batch(for indexPath: IndexPath) -> Int {
        return  1 + indexPath.row / 50
    }
    
    fileprivate func preloadNextBatch(after indexPath: IndexPath) {
        let currentBatch = batch(for: indexPath)
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