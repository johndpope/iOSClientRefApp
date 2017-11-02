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
    
    var didActivate: (Bool) -> Void = { _ in }
    var title: String {
        return dynamicContent.title
    }
    let dynamicContent: DynamicContentCategory
    var actionIdentifier: MainMenuViewController.Action {
        return .content(segue: dynamicContent)
    }
    var isActive: Bool {
        didSet {
            didActivate(isActive)
        }
    }
    var textColor: UIColor {
        return isActive ? UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1) : UIColor.lightGray
    }
    
    init(dynamicContent: DynamicContentCategory, active: Bool = false) {
        self.dynamicContent = dynamicContent
        self.isActive = active
    }
}
