//
//  SimpleEpgViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2018-01-12.
//  Copyright © 2018 emp. All rights reserved.
//

import UIKit
import Exposure

extension Program: LocalizedEntity {
    var locales: [String] {
        return asset?.localized?.flatMap{ $0.locale } ?? []
    }
    
    func localizedData(locale: String) -> LocalizedData? {
        return asset?.localized?.filter{ $0.locale == locale }.first
    }
    
    func localizations() -> [LocalizedData] {
        return asset?.localized ?? []
    }
    
    func anyTitle(locale: String) -> String {
        if let title = title(locale: locale), title != "" { return title }
        else if let originalTitle = asset?.originalTitle, originalTitle != "" { return originalTitle }
        else if let assetId = asset?.assetId { return assetId }
        return "NO TITIE"
    }
    
    func anyDescription(locale: String) -> String {
        if let description = localizedData(locale: locale)?.allDescriptions().last {
            return description
        }
        return localizations().flatMap{ $0.allDescriptions() }.last ?? ""
    }
}

class SimpleEpgViewController: UIViewController {
    
    let viewModel = ListViewModel<Program>()
    var onSelected: (Program) -> Void = { _ in }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "EPGPreviewCell", bundle: nil),
                           forCellReuseIdentifier: "EPGPreviewCell")
        tableView.register(UINib(nibName: "EpgUnavailableCell", bundle: nil),
                           forCellReuseIdentifier: "EpgUnavailableCell")
        
        
        viewModel.onPrepared = { [weak self] models, error in
            // reload
            self?.tableView.reloadData()
        }
        viewModel.executeResuest()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SimpleEpgViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.content.isEmpty ? 1 : viewModel.content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !viewModel.content.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: "EPGPreviewCell", for: indexPath)
        }
        else {
            return tableView.dequeueReusableCell(withIdentifier: "EpgUnavailableCell", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let preview = cell as? EPGPreviewCell {
            let vm = viewModel.content[indexPath.row]
            
            preview.reset()
            preview.bind(viewModel: vm)
            //            preview.apply(brand: brand)
            //            preview.markAs(playing: indexPath.row == nowPlayingIndex)
        }
    }
}

extension SimpleEpgViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if !viewModel.content.isEmpty {
            return !viewModel.content[indexPath.row].isUpcoming
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if !viewModel.content.isEmpty {
            let vm = viewModel.content[indexPath.row]
            onSelected(vm.model)
        }
    }
}


