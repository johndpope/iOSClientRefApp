//
//  CarouselView.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-22.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Kingfisher

class CarouselView: UICollectionViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate(set) var viewModel: CarouselViewModel<HeroPromotionEditorial, HeroItemPromotionEditorial>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(UINib(nibName: "HeroPromotionCell", bundle: nil), forCellWithReuseIdentifier: "heroCell")

        collectionView.register(UINib(nibName: "CarouselHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "carouselHeader")
        
        collectionView.register(UINib(nibName: "CarouselFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "carouselFooter")

        collectionView.delegate = self
        collectionView.dataSource = self
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
        }
        
    }
    
    func bind(viewModel: CarouselViewModel<HeroPromotionEditorial, HeroItemPromotionEditorial>) {
        self.viewModel = viewModel
        collectionView.collectionViewLayout = viewModel.layout
        collectionView.reloadData()
    }
    
}



extension CarouselView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "heroCell", for: indexPath) as! HeroPromotionCell
    }
}

extension CarouselView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("CarouselView",#function)
        
        preloadNextBatch(after: indexPath)
        if let cell = cell as? HeroPromotionCell {
            cell.reset()
            if viewModel.editorial.usesItemSpecificEditorials {
                let vm = viewModel.content[indexPath.row]
                cell.title.text = vm.editorial?.title
                cell.editorialText.text = vm.editorial?.text
            }
            
            
            // Promotional Art
            let cellWidth = collectionView.bounds.size.width
            if let url = viewModel.imageUrl(for: indexPath.row) {
                let imageOptions = viewModel.thumbnailOptions(forCellWidth: cellWidth)
                cell.heroBanner
                    .kf
                    .setImage(with: url, placeholder: #imageLiteral(resourceName: "assetPlaceholder"), options: imageOptions) { [weak self] (image, error, cache, url) in
                        if let error = error {
                            print("Kingfisher: ",error)
                        }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "carouselHeader", for: indexPath) as! CarouselHeaderView
            view.title.text = viewModel.editorial.title
            view.editorialText.text = viewModel.editorial.text
            return view
        }
        
        if kind == UICollectionElementKindSectionFooter {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "carouselFooter", for: indexPath) as! CarouselFooterView
            return view
        }
        return UICollectionReusableView()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
//        let vm = viewModel.content[indexPath.row]
//        cellSelected(vm.asset)
    }
}


extension CarouselView: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.flatMap{ viewModel.imageUrl(for: $0.row) }
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
