//
//  StretchyCarouselHeaderView.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-30.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure

class StretchyCarouselHeaderView: UICollectionReusableView {

    @IBOutlet weak var collectionView: UICollectionView!
    var viewModel: CarouselViewModel!
    var selectedAsset: (Asset) -> Void = { _ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        collectionView.register(UINib(nibName: "BannerPromotionCell", bundle: nil), forCellWithReuseIdentifier: "bannerCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    func bind(viewModel: CarouselViewModel) {
        self.viewModel = viewModel
        print("HEADER BEFORE bind(viewModel",collectionView.contentOffset)
//        self.collectionView.reloadData()
//        self.collectionView.layoutIfNeeded()
        self.collectionView.collectionViewLayout = viewModel.editorial.layout
        self.collectionView.reloadData()
        print("HEADER AFTER bind(viewModel",collectionView.contentOffset)
    }
}

extension StretchyCarouselHeaderView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? BannerPromotionCell {
            cell.configure(with: viewModel.editorial as? BannerPromotionEditorial,
                           for: indexPath.row, size: collectionView.bounds.size)
            cell.selectedAsset = { [weak self] asset in
                self?.selectedAsset(asset)
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension StretchyCarouselHeaderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.editorial.content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "bannerCell", for: indexPath)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
