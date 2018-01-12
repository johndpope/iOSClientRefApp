//
//  SimpleCarouselViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2018-01-12.
//  Copyright © 2018 emp. All rights reserved.
//

import UIKit
import Exposure

class PresentableViewModel<Model> {
    let model: Model
    
    init(model: Model) {
        self.model = model
    }
}
extension PresentableViewModel where Model: LocalizedEntity {
    var locales: [String] {
        return model.locales
    }
    
    func localizedData(locale: String) -> LocalizedData? {
        return model.localizedData(locale: locale)
    }
    
    func localizations() -> [LocalizedData] {
        return model.localizations()
    }
    
    func anyTitle(locale: String) -> String {
        return model.anyTitle(locale: locale)
    }
    
    func anyDescription(locale: String) -> String {
        return model.anyDescription(locale: locale)
    }
}

extension PresentableViewModel where Model == Program {
    var isUpcoming: Bool {
        guard let start = model.startDate else { return false }
        
        let current = Date()
        
        return start > current
    }
    
    var isLive: Bool {
        guard let start = model.startDate, let end = model.endDate else { return false }
        
        let current = Date()
        
        return start < current && current < end
    }
    
    func programLiveProgress() -> Float? {
        guard isLive else { return nil }
        
        guard let start = model.startDate, let end = model.endDate else { return nil }
        
        let current = Date()
        
        let startMillis = Float(start.millisecondsSince1970)
        let currentMillis = Float(current.millisecondsSince1970)
        let endMillis = Float(end.millisecondsSince1970)
        
        return (currentMillis - startMillis) / (endMillis - startMillis)
    }
    
    func programDurationString(locale: String) -> String? {
        let current = Date()
        
        guard let start = model.startDate, let end = model.endDate else { return nil }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let startTime = timeFormatter.string(from: start)
        let endTime = timeFormatter.string(from: end)
        
        // Start | End | Current
        //
        //   X   |  X  |    X    ->  Today
        //  X-1  |  X  |    X    ->  Yesterday
        //   X   | X+1 |    X    ->  Tomorrow
        //
        // Otherwise, just use date
        let startComponents = Calendar.current.dateComponents([.day,.month], from: start)
        let endComponents = Calendar.current.dateComponents([.day,.month], from: end)
        let currentComponents = Calendar.current.dateComponents([.day,.month], from: current)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        if startComponents.day! == endComponents.day! {
            if startComponents.day! == currentComponents.day! {
                return "Today " + startTime + " - " + endTime
            }
            else if endComponents.day! == (currentComponents.day! - 1) {
                return "Yesterday " + startTime + " - " + endTime
            }
            else if startComponents.day! == (currentComponents.day! - 1) {
                return "Tomorrow " + startTime + " - " + endTime
            }
            else {
                return dateFormatter.string(from: start) + " " + startTime + " - " + endTime
            }
        }
        else {
            dateFormatter.dateFormat = "MMM d HH:mm"
            return dateFormatter.string(from: start) + " - " + dateFormatter.string(from: end)
        }
    }
}

class ListViewModel<Model> {
    fileprivate(set) var content: [PresentableViewModel<Model>] = []
    var executeResuest: () -> Void = { _ in }
    var onPrepared: ([Model]?, ExposureError?) -> Void = { _,_ in }
    
    func prepare(content: [Model]?, error: ExposureError?) {
        self.content = content?.map{ PresentableViewModel(model: $0) } ?? []
        onPrepared(content,error)
    }
}

class GenericCollectionViewDelegate: NSObject, UICollectionViewDelegate {
    var willDisplay: (UICollectionView, UICollectionViewCell, IndexPath) -> Void = { _,_,_  in }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        willDisplay(collectionView, cell, indexPath)
    }
    
    var didSelect: (UICollectionView, IndexPath) -> Void = { _,_ in }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelect(collectionView, indexPath)
    }
}


class GenericCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    var numberOfItemsInSection: ((UICollectionView, Int) -> Int)!
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection(collectionView, section)
    }
    
    var cellForItemAt: ((UICollectionView, IndexPath) -> UICollectionViewCell)!
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellForItemAt(collectionView, indexPath)
    }
}

class SimpleCarouselViewController<Model: LocalizedEntity>: UIViewController {
    
    let viewModel = ListViewModel<Model>()
    var onSelected: (Model?) -> Void = { _ in }
    
    @IBOutlet weak var collectionView: UICollectionView!
    let genericDelegate = GenericCollectionViewDelegate()
    var genericDataSource = GenericCollectionViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "AssetPreviewCell", bundle: nil), forCellWithReuseIdentifier: "AssetPreviewCell")
        
        hookCollectionView()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 2*preferredCellSpacing
        flowLayout.itemSize = preferredCellSize(forWidth: view.frame.size.width)
        flowLayout.minimumLineSpacing = 0
        collectionView.contentInset = edgeInsets
        collectionView.collectionViewLayout = flowLayout
        
        viewModel.onPrepared = { [weak self] models, error in
            // reload
            self?.collectionView.reloadData()
        }
        viewModel.executeResuest()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: SlidingMenuDelegate
    var slidingMenuController: SlidingMenuController?
    
    var aspectRatio: CGFloat = 2/3
    var preferredCellSpacing: CGFloat = 0
    var preferredCellsPerRow: Int = 1
    var labelHeight: CGFloat = 20
    var edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    fileprivate(set) var content: [AssetViewModel] = []
    
}

extension SimpleCarouselViewController {
    func preferredCellSize(forWidth width: CGFloat) -> CGSize {
        let thumbSize = preferredThumbnailSize(forWidth: width)
        return CGSize(width: thumbSize.width, height: thumbSize.height + labelHeight)
    }
    
    func preferredThumbnailSize(forWidth width: CGFloat) -> CGSize {
        let cellsPerRow = CGFloat(preferredCellsPerRow)
        let cellWidth = (width - edgeInsets.left - edgeInsets.right)/cellsPerRow - (cellsPerRow - 1)*preferredCellSpacing
        let cellHeight =  cellWidth * aspectRatio
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension SimpleCarouselViewController {
    fileprivate func hookCollectionView() {
        // MARK: Delegate
        collectionView.delegate = genericDelegate
        
        genericDelegate.willDisplay = { [weak self] collectionView, cell, indexPath in
            guard let `self` = self else { return }
            
            //            preloadNextBatch(after: indexPath)
            if let preview = cell as? AssetPreviewCell {
                let vm = self.viewModel.content[indexPath.row]
                
                preview.reset()
                preview.thumbnail(title: vm.anyTitle(locale: "en"))
                //                preview.apply(brand: brand)
                
                // We need aspectFit for "general" thumbnail since we have little control over screen size.
                preview.thumbnailView.contentMode = .scaleAspectFit
                //                if let url = self.viewModel.imageUrl(for: indexPath) {
                //                    preview
                //                        .thumbnailView
                //                        .kf
                //                        .setImage(with: url, options: viewModel.thumbnailImageOptions(for: collectionView.bounds.width)) { (image, error, cache, url) in
                //                            // AspectFill for images to make sure they "fill" the entire preview.
                //                            preview.thumbnailView.contentMode = .scaleAspectFill
                //                            if let error = error {
                //                                print("Kingfisher: ",error)
                //                            }
                //                    }
                //                }
            }
        }
        
        genericDelegate.didSelect = { [weak self] collectionView, indexPath in
            guard let `self` = self else { return }
            collectionView.deselectItem(at: indexPath, animated: true)
            let vm = self.viewModel.content[indexPath.row]
            self.onSelected(vm.model)
        }
        
        
        // MARK: DataSource
        collectionView.dataSource = genericDataSource
        
        genericDataSource.numberOfItemsInSection = { [unowned self] collectionView, section in
            return self.viewModel.content.count
        }
        
        genericDataSource.cellForItemAt = { collectionView, indexPath in
            return collectionView.dequeueReusableCell(withReuseIdentifier: "AssetPreviewCell", for: indexPath) as! AssetPreviewCell
        }
    }
}


extension SimpleCarouselViewController: SlidingMenuDelegate {
    
}

