//
//  MainMenuItemType.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-28.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

protocol MainMenuItemType: class {
    static var reuseIdentifier: String { get }
    var brand: Branding.ColorScheme { get set }
}

