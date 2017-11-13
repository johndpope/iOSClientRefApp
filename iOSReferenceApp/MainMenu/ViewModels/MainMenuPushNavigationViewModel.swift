//
//  MainMenuPushNavigationViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class MainMenuPushNavigationViewModel: MainMenuItemType, MainMenuActionType {
    static var reuseIdentifier: String {
        return "pushNavigationCell"
    }
    
    let actionIdentifier: MainMenuViewController.Action
    
    let title: String
    let image: UIImage?
    
    var textColor: UIColor {
        return brand.text.secondary
    }
    
    var brand: Branding.ColorScheme = Branding.ColorScheme.default
    
    init(title: String, action: MainMenuViewController.Action, image: UIImage? = nil) {
        self.title = title
        self.image = image
        self.actionIdentifier = action
    }
}

