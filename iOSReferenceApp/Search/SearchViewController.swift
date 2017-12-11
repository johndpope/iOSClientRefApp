//
//  SearchViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-15.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Kingfisher
import Exposure

class SearchViewController: UIViewController {

    var brand: Branding.ColorScheme = Branding.ColorScheme.default
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchContainerView: UIView!
    var searchController: UISearchController!
    
    var viewModel: SearchViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "AssetPreviewCell", bundle: nil), forCellWithReuseIdentifier: "AssetPreviewCell")
        
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
//        searchController.delegate = self
        
        // Setting the tint color here is required as it somehow does not work in IB
        
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search..."
        searchController.searchBar.showsCancelButton = true
        
        searchContainerView.addSubview(searchController.searchBar)
        searchController.searchBar.sizeToFit()
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationItem.hidesBackButton = true
        
        // Make sure the search bar is active once the view loads
        searchController.searchBar.becomeFirstResponder()
        apply(brand: brand)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SearchViewController: AuthorizedEnvironment {
    func authorize(environment: Environment, sessionToken: SessionToken) {
        viewModel = SearchViewModel(environment: environment,
                                    sessionToken: sessionToken)
        //viewModel.authorize(environment: environment, sessionToken: sessionToken)
    }
    var environment: Environment {
        return viewModel.environment
    }
    
    var sessionToken: SessionToken {
        return viewModel.sessionToken
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "AssetPreviewCell", for: indexPath) as! AssetPreviewCell
    }
}

extension SearchViewController: UICollectionViewDelegate {
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
                    .setImage(with: url, options: thumbnailImageOptions) { (image, error, cache, url) in
                        // AspectFill for images to make sure they "fill" the entire preview.
                        preview.thumbnailView.contentMode = .scaleAspectFill
                        if let error = error {
                            print("Kingfisher: ",error)
                        }
                }
            }
        }
    }
    
    private var thumbnailImageProcessor: ImageProcessor {
        let thumbSize = viewModel.preferredThumbnailSize(forWidth: collectionView.bounds.size.width)
        let resizeProcessor = CrispResizingImageProcessor(referenceSize: thumbSize, mode: ContentMode.aspectFill)
        let croppingProcessor = CroppingImageProcessor(size: thumbSize)
        let roundedRectProcessor = RoundCornerImageProcessor(cornerRadius: 6)
        return (resizeProcessor>>croppingProcessor)>>roundedRectProcessor
    }
    
    private var thumbnailImageOptions: KingfisherOptionsInfo {
        return [
            .backgroundDecode,
            .cacheMemoryOnly,
            .processor(thumbnailImageProcessor)
        ]
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vm = viewModel.content[indexPath.row]
        self.performSegue(withIdentifier: "segueListToDetails", sender: vm.asset)
    }
}


extension SearchViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueListToDetails" {
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

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.preferredCellSize(forWidth: collectionView.bounds.size.width)
    }
}

extension SearchViewController: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.flatMap{ viewModel.imageUrl(for: $0) }
        ImagePrefetcher(urls: urls).start()
    }
}


extension SearchViewController {
    func batch(for indexPath: IndexPath) -> Int {
        return  1 + indexPath.item / 50
    }
    
    fileprivate func preloadNextBatch(after indexPath: IndexPath) {
        let currentBatch = batch(for: indexPath)
        viewModel.fetchMetadata(batch: currentBatch+1) { [unowned self] (batch, error) in
            if let error = error {
                print(error)
            }
//            else if batch == currentBatch {
//                self.collectionView.reloadData()
//            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.popViewController(animated: true)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.resignFirstResponder()
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = viewModel.currentSearchTerm
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            viewModel.clear()
            collectionView.reloadData()
        }
        print("Search text changed: ",searchText)
    }
}

//extension SearchViewController: UISearchControllerDelegate {
//    public func willDismissSearchController(_ searchController: UISearchController) {
//
//    }
//    public func didDismissSearchController(_ searchController: UISearchController) {
//
//    }
//}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("updateSearchResults")
        if let searchString = searchController.searchBar.text {
            viewModel.search(query: searchString) { [weak self] error in
                if let error = error {
                    self?.showMessage(title: "Exposure Error", message: error.message)
                }
                else {
                    self?.collectionView.reloadData()
                }
            }
        }
    }
}

extension SearchViewController: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        collectionView.backgroundColor = brand.backdrop.primary
        view.backgroundColor = brand.backdrop.primary
        searchController.searchBar.apply(brand: brand)
    }
}
