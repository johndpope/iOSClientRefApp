//
//  CarouselView.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-22.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Kingfisher

class CarouselView: UICollectionViewCell {//UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate(set) var viewModel: CarouselViewModel<CarouselEditorialFakeData, CarouselItemEditorialFakeData>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(UINib(nibName: "HeroPromotionalCell", bundle: nil), forCellWithReuseIdentifier: "heroCell")

        collectionView.register(UINib(nibName: "CarouselHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "carouselHeader")
        
        collectionView.register(UINib(nibName: "CarouselFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "carouselFooter")

        collectionView.delegate = self
        collectionView.dataSource = self
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
        }
        
        let layout = HeroPromotionalLayout()
        layout.delegate = self
        collectionView.collectionViewLayout = layout
    }
    
    func bind(viewModel: CarouselViewModel<CarouselEditorialFakeData, CarouselItemEditorialFakeData>) {
        self.viewModel = viewModel
        collectionView.reloadData()
    }
    
}



extension CarouselView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.editorial.promotionalType {
        case .hero:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "heroCell", for: indexPath) as! HeroPromotionalCell
        }
        
    }
}

extension CarouselView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        preloadNextBatch(after: indexPath)
        if let preview = cell as? HeroPromotionalCell {
            if viewModel.editorial.usesItemSpecificEditorials {
                let vm = viewModel.content[indexPath.row]
                preview.title.text = vm.editorial?.editorialTitle
                preview.editorialText.text = vm.editorial?.editorialText
            }
            
            
            // Promotional Art
            let cellWidth = collectionView.bounds.size.width
            if let url = viewModel.imageUrl(for: indexPath.row) {
                let imageOptions = viewModel.thumbnailOptions(forCellWidth: cellWidth)
                preview
                    .heroBanner
                    .kf
                    .setImage(with: url, placeholder: #imageLiteral(resourceName: "assetPlaceholder"), options: imageOptions) { [weak self] (image, error, cache, url) in
                        if let error = error {
                            print("Kingfisher: ",error)
                        }
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "carouselHeader", for: indexPath) as! CarouselHeaderView
            return view
        }
        if kind == UICollectionElementKindSectionFooter {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "carouselFooter", for: indexPath) as! CarouselFooterView
            return view
        }
        return UICollectionReusableView()
    }
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if kind == UICollectionElementKindSectionHeader {
//            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "carouselHeader", for: indexPath) as! CarouselHeaderView
//
//            if viewModel.editorial.usesCarouselSpecificEditorial {
//                view.editorialText.text = viewModel.editorial.editorialText
//                view.title.text = viewModel.editorial.editorialTitle
//            }
//            else {
////                view.editorialText.text = viewModel.content[indexPath.row].editorial?.editorialText
////                view.title.text = viewModel.content[indexPath.row].editorial?.editorialTitle
//            }
//            return view
//        }
//
//        if kind == UICollectionElementKindSectionFooter {
//            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "carouselFooter", for: indexPath) as! CarouselFooterView
//            return view
//        }
//        return UICollectionReusableView()
//    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
//        let vm = viewModel.content[indexPath.row]
//        cellSelected(vm.asset)
    }
}

extension CarouselView: HeroPromotionalLayoutDelegate {
    func carouselSpecificEditorialHeight() -> CGFloat? {
        return 43
    }
    func itemSpecificEditorialHeight() -> CGFloat? {
        return 43
    }
    func carouselFooterHeight() -> CGFloat {
        return 60
    }

    func pageWidth() -> CGFloat {
        return collectionView.bounds.size.width
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
