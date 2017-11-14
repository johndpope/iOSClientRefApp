//
//  MainMenuStaticDataViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class MainMenuStaticDataViewModel: MainMenuItemType {
    static var reuseIdentifier: String {
        return "staticDataCell"
    }
    
    var brand: Branding.ColorScheme = Branding.ColorScheme.default
    
    let text: String
    var textColor: UIColor {
        return brand.text.tertiary
    }
    
    init(text: String) {
        self.text = text
    }
}
