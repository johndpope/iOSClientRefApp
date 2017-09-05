//
//  HorizontalScrollRow.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-05-31.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Kingfisher
import Exposure

class HorizontalScrollRow: UITableViewCell {
    
    var cellSelected: (Asset) -> Void = { _ in }
    
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate(set) var viewModel: CategoryViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(UINib(nibName: "AssetPreviewCell", bundle: nil), forCellWithReuseIdentifier: "AssetPreviewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bind(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
    }
}

extension HorizontalScrollRow: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "AssetPreviewCell", for: indexPath) as! AssetPreviewCell
    }
}

extension HorizontalScrollRow: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        preloadNextBatch(after: indexPath)
        if let preview = cell as? AssetPreviewCell {
            let vm = viewModel.content[indexPath.row]
            
            preview.reset()
            if let url = imageUrl(for: indexPath) {
                preview.thumbnailView.kf.setImage(with: url) { (image, error, _, url) in
                    if let error = error {
                        print("Kingfisher: ",error)
                        preview.thumbnail(title: vm.anyTitle(locale: "en"))
                    }
                }
            }
            else {
                preview.thumbnail(title: vm.anyTitle(locale: "en"))
            }
        }
    }
    
    fileprivate func imageUrl(for indexPath: IndexPath) -> URL? {
        return viewModel.content[indexPath.row].validImageUrls(locale: "en").first
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vm = viewModel.content[indexPath.row]
        cellSelected(vm.asset)
    }
}

extension HorizontalScrollRow: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.preferredCellSize
    }
    
}

extension HorizontalScrollRow: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.flatMap{ imageUrl(for: $0) }
        ImagePrefetcher(urls: urls).start()
    }
}

extension HorizontalScrollRow {
    func batch(for indexPath: IndexPath) -> Int {
        return  1 + indexPath.row / 50
    }
    
    fileprivate func preloadNextBatch(after indexPath: IndexPath) {
        let currentBatch = batch(for: indexPath)
        viewModel.fetchMetadata(batch: currentBatch+1) { [unowned self] error in
            if let error = error {
                print(error)
            }
            else {
                self.collectionView.reloadData()
            }
        }
    }
}
