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
        
        
        
        static var `default`: ColorScheme {
//            let text = Branding.ColorScheme.Text(primary: UIColor.redBeePaper,
//                                                 secondary: UIColor.redBeeLightGrey)
//            let backdrop = Branding.ColorScheme.Backdrop(primary: UIColor.redBeeBlack,
//                                                         secondary: UIColor.redBeeCharcoal)
//            let primary = UIColor.redBeeRed
            let text = Branding.ColorScheme.Text(primary: UIColor.darkGray,
                                                 secondary: UIColor.lightGray)
            let backdrop = Branding.ColorScheme.Backdrop(primary: UIColor.cyan,
                                                         secondary: UIColor.brown)
            let primary = UIColor.gray
            
            let fadeGradient = Branding.ColorScheme.Gradient(start: CGPoint(x: 0.5, y: 0),
                                                             end: CGPoint(x: 0.5, y: 1),
                                                             colors: [UIColor("#222224"), UIColor.cyan])
            
            return Branding.ColorScheme(accent: primary,
                                        text: text,
                                        backdrop: backdrop,
                                        fade: fadeGradient)
        }
        
        static var test: ColorScheme {
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
