//
//  MainMenuContentViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class MainMenuContentViewModel: MainMenuItemType, MainMenuActionType {
    static var reuseIdentifier: String {
        return "contentCell"
    }
    
    let title: String
    let actionIdentifier: MainMenuViewController.Action?
    var isActive: Bool
    var textColor: UIColor {
        return isActive ? UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1) : UIColor.lightGray
    }
    
    init(title: String, active: Bool = false, action: MainMenuViewController.Action? = nil) {
        self.title = title
        self.isActive = active
        self.actionIdentifier = action
    }
}
