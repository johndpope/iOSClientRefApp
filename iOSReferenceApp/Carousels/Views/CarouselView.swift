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

    var brand: Branding.ColorScheme = Branding.ColorScheme.default
    
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedAsset: (Asset) -> Void = { _ in }
    
    fileprivate(set) var viewModel: CarouselViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(UINib(nibName: "HeroPromotionCell", bundle: nil), forCellWithReuseIdentifier: "heroCell")
        collectionView.register(UINib(nibName: "PortraitTrioPromotionCell", bundle: nil), forCellWithReuseIdentifier: "portraitTrioCell")
        collectionView.register(UINib(nibName: "BasicPromotionCell", bundle: nil), forCellWithReuseIdentifier: "basicCell")

        collectionView.register(UINib(nibName: "CarouselHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "carouselHeader")
        
        collectionView.register(UINib(nibName: "CarouselFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "carouselFooter")

        collectionView.delegate = self
        collectionView.dataSource = self
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
        }
        
    }
    
    func bind(viewModel: CarouselViewModel) {
        self.viewModel = viewModel
        self.collectionView.collectionViewLayout = viewModel.editorial.layout
        self.collectionView.reloadData()
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
        else if viewModel.editorial is BasicPromotionEditorial {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "basicCell", for: indexPath) as! BasicPromotionCell
        }
        return UICollectionViewCell()
    }
}

extension CarouselView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        preloadNextBatch(after: indexPath)
        if let cell = cell as? HeroPromotionCell {
            cell.configure(with: viewModel.editorial as? HeroPromotionEditorial,
                           for: indexPath.row, size: collectionView.bounds.size)
            cell.apply(brand: brand)
            cell.selectedAsset = { [weak self] asset in
                self?.selectedAsset(asset)
            }
        }
        else if let cell = cell as? PortraitTrioPromotionCell {
            cell.configure(with: viewModel.editorial as? PortraitTrioPromotionEditorial,
                           for: indexPath.row, size: collectionView.bounds.size)
            cell.apply(brand: brand)
            cell.selectedAsset = { [weak self]  asset in
                self?.selectedAsset(asset)
            }
        }
        else if let cell = cell as? BasicPromotionCell {
            cell.configure(with: viewModel.editorial as? BasicPromotionEditorial,
                           for: indexPath.row, size: collectionView.bounds.size)
            cell.apply(brand: brand)
            cell.selectedAsset = { [weak self]  asset in
                self?.selectedAsset(asset)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let view = view as? CarouselHeaderView, elementKind == UICollectionElementKindSectionHeader {
            view.configure(with: viewModel.editorial)
            view.apply(brand: brand)
        }
        else if let view = view as? CarouselFooterView, elementKind == UICollectionElementKindSectionFooter {
            view.apply(brand: brand)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "carouselHeader", for: indexPath) as! CarouselHeaderView
        }
        
        if kind == UICollectionElementKindSectionFooter {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "carouselFooter", for: indexPath) as! CarouselFooterView
        }
        return UICollectionReusableView()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
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
//        let currentBatch = batch(for: indexPath)
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

extension CarouselView: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        collectionView.backgroundColor = brand.backdrop.primary
        contentView.backgroundColor = brand.backdrop.primary
    }
}
