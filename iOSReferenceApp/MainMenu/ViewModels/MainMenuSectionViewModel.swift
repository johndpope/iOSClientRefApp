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
    
    init(rows: [MainMenuItemType]) {
        self.rows = rows
    }
    
    let backgroundColor: UIColor = UIColor(red: 0.047, green: 0.055, blue: 0.059, alpha: 1)
    let height: CGFloat = 3
    
    subscript(index: Int) -> MainMenuItemType {
        get {
            return rows[index]
        }
    }
}
