//
//  SearchViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-15.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import CoreGraphics
import Exposure

class SearchViewModel: AuthorizedEnvironment, AssetListType {
    
    var environment: Environment
    var sessionToken: SessionToken
    func authorize(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
    
    fileprivate(set) var content: [AssetViewModel] = []
    fileprivate(set) var isSearching: Bool = false
    fileprivate(set) var currentSearchTerm: String?
    
    init(environment: Environment, sessionToken: SessionToken) {
        self.environment = environment
        self.sessionToken = sessionToken
    }
    
    fileprivate var loadedBatches: Set<Int> = []
    fileprivate var inProgressBatches: Set<Int> = []
}

extension SearchViewModel {
    
    var batchSize: Int {
        return 50
    }
    
    func fetchMetadata(batch: Int, callback: @escaping (Int, ExposureError?) -> Void) {
        guard !loadedBatches.contains(batch) else { return }
        guard !inProgressBatches.contains(batch) else { return }
        guard let searchTerm = currentSearchTerm else { return }
        
        inProgressBatches.insert(batch)
        let shouldResetContent = isSearching
        Search(environment: environment)
            .query(for: searchTerm)
            .filter(locale: "en")
            .show(page: batch, spanning: batchSize)
            .request()
            .validate()
            .response{
                if let success = $0.value {
                    self.process(response: success.items, shouldReset: shouldResetContent)
                    self.inProgressBatches.remove(batch)
                    self.loadedBatches.insert(batch)
                    callback(batch, nil)
                }
                
                if let error = $0.error {
                    print(error)
                    callback(batch, error)
                    self.inProgressBatches.remove(batch)
                }
        }
    }
    
    fileprivate func process(response: [SearchResponse], shouldReset: Bool) {
        let viewModels = response.flatMap{ AssetViewModel(asset: $0.asset ) }
        if shouldReset {
            content = viewModels
        }
        else {
            viewModels.forEach{ content.append($0) }
        }
    }
}

extension SearchViewModel {
    var preferredCellSize: CGSize {
        return CGSize.zero
    }
    
    var preferredThumbnailSize: CGSize {
        return CGSize.zero
    }
    
    func preferredCellSize(forWidth width: CGFloat) -> CGSize {
        let thumbSize = preferredThumbnailSize(forWidth: width)
        return CGSize(width: thumbSize.width, height: thumbSize.height + labelHeight)
    }
    
    func preferredThumbnailSize(forWidth width: CGFloat) -> CGSize {
        let cellWidth = width/preferredCellsPerRow - (preferredCellsPerRow - 1)*previewCellPadding
        let cellHeight =  cellWidth * 9 / 6
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    var preferredCellsPerRow: CGFloat {
        return 3
    }
    
    var previewCellPadding: CGFloat {
        return 5
    }
    
    private var labelHeight: CGFloat {
        return 20
    }
    
    
    func anyTitle() -> String? {
        return "Search".uppercased()
    }
}

extension SearchViewModel {
    func clear() {
        resetSearch(for: nil)
        content = []
    }
    
    func search(query string: String, callback: @escaping (ExposureError?) -> Void) {
        resetSearch(for: string)
        guard string != "" else { return }
        isSearching = true
        fetchMetadata(batch: 1) { [weak self] batch, error in
            callback(error)
            self?.isSearching = false
        }
    }
    
    fileprivate func resetSearch(for string: String?) {
        currentSearchTerm = string
        inProgressBatches = Set()
        loadedBatches = Set()
    }
}
