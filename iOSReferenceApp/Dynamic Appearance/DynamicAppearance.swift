//
//  DynamicAppearance.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-10.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit


public class TextButton: UIButton { }
public class IconButton: UIButton { }
//public class HeaderText: UILabel { }
//public class CopyText: UILabel { }


protocol DynamicAppearance {
    func apply(brand: Branding.ColorScheme)
}



struct Branding {
    struct ColorScheme {
        let accent: UIColor
        let text: Text
        let backdrop: Backdrop
        let fade: Gradient
        
        struct Gradient {
            let start: CGPoint
            let end: CGPoint
            let colors: [UIColor]
        }
        
        struct Text {
            let primary: UIColor
            let secondary: UIColor
        }
        
        struct Backdrop {
            let primary: UIColor
            let secondary: UIColor
        }
        
        
        
        /// The defalt color scheme
        static var `default`: ColorScheme {
            return redBee
        }
        
        /// Used to indicate missing or malconfigured ui elements. Apply to `default`
        static var testScheme: ColorScheme {
            let text = Branding.ColorScheme.Text(primary: UIColor.blue,
                                                 secondary: UIColor.magenta)
            let backdrop = Branding.ColorScheme.Backdrop(primary: UIColor.red,
                                                         secondary: UIColor.orange)
            let primary = UIColor.green
            
            let fadeGradient = Branding.ColorScheme.Gradient(start: CGPoint(x: 0.5, y: 0),
                                                             end: CGPoint(x: 0.5, y: 1),
                                                             colors: [UIColor("#222224"), UIColor.red])
            
            return Branding.ColorScheme(accent: primary,
                                        text: text,
                                        backdrop: backdrop,
                                        fade: fadeGradient)
        }
        
        static var redBee: ColorScheme {
            let text = Branding.ColorScheme.Text(primary: UIColor.redBeePaper,
                                                 secondary: UIColor.redBeeLightGrey)
            let backdrop = Branding.ColorScheme.Backdrop(primary: UIColor.redBeeBlack,
                                                         secondary: UIColor.redBeeCharcoal)
            let primary = UIColor.redBeeRed
            let fadeGradient = Branding.ColorScheme.Gradient(start: CGPoint(x: 0.5, y: 0),
                                                             end: CGPoint(x: 0.5, y: 1),
                                                             colors: [UIColor("#222224"), UIColor.redBeeBlack])
            
            return Branding.ColorScheme(accent: primary,
                                        text: text,
                                        backdrop: backdrop,
                                        fade: fadeGradient)
        }
    }
    
    
    struct Typography {
        let header: String
        let copyText: String
    }
//    let logo: String
//
//
//    let primary: Styling
//    let secondary: Styling
//
//
//    struct Styling {
//        /// Emphasized styling
//        let accent: Component
//
//        /// Complementary styling
//        let complement: Component?
//    }
//
//    struct Component {
//        ///
//        let tint: UIColor
//
//        /// Background color
//        let backdrop: UIColor
//    }
//
//    struct Action {
//        let constructive: UIColor
//        let destructive: UIColor
//    }

}

extension UIProgressView: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        progressTintColor = brand.accent
        trackTintColor = brand.text.secondary
    }
}
extension UISlider: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        minimumTrackTintColor = brand.accent
        thumbTintColor = brand.accent
        maximumTrackTintColor = brand.text.secondary
    }
}

extension SkyFloatingLabelTextField: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        titleColor = brand.accent
        selectedTitleColor = brand.accent
        clearButtonColor = brand.accent
        
        textColor = brand.text.primary
        lineColor = brand.text.primary
        selectedLineColor = brand.text.primary
    }
}

extension UISearchBar: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        tintColor = brand.accent
        searchBarStyle = UISearchBarStyle.minimal
        barStyle = UIBarStyle.black
    }
}

extension UINavigationController: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        navigationBar.apply(brand: brand)
    }
}

extension UINavigationBar: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        barStyle = .black
        tintColor = brand.text.primary
        barTintColor = brand.backdrop.primary
        titleColor = brand.text.primary
    }
    
    var titleColor: UIColor? {
        get {
            if let attributes = self.titleTextAttributes {
                return attributes[NSForegroundColorAttributeName] as? UIColor
            }
            return nil
        }
        set {
            if let value = newValue {
                self.titleTextAttributes = [NSForegroundColorAttributeName: value]
            }
        }
    }
    
    var titleFont: UIFont? {
        get {
            if let attributes = self.titleTextAttributes {
                return attributes[NSFontAttributeName] as? UIFont
            }
            return nil
        }
        set {
            if let value = newValue {
                self.titleTextAttributes = [NSFontAttributeName: value]
            }
        }
    }
}

extension UINavigationItem: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        leftBarButtonItems?.forEach { $0.apply(brand: brand) }
        rightBarButtonItems?.forEach { $0.apply(brand: brand) }
    }
}

extension UIBarButtonItem: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        tintColor = brand.text.primary
    }
}

