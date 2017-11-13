//
//  MainMenuSectionViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class MainMenuSectionViewModel {
    var rows: [MainMenuItemType]
    
    var brand: Branding.ColorScheme = Branding.ColorScheme.default {
        didSet { rows.forEach { $0.brand = brand } }
    }
    
    init(rows: [MainMenuItemType]) {
        self.rows = rows
    }
    
    var backgroundColor: UIColor {
        return brand.backdrop.secondary
    }
    
    let height: CGFloat = 3
    
    subscript(index: Int) -> MainMenuItemType {
        get {
            return rows[index]
        }
    }
}
