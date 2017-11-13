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



//extension TextButton {
//    static func apply(brand: Branding.TextButton)  {
//        appearance().setTitleColor(brand.text, for: [])
//        appearance().setTitleColor(brand.disabled, for: UIControlState.disabled)
//    }
//}
//
//extension UIProgressView {
//    static func apply(brand: Branding.Progress) {
//        appearance().progressTintColor = brand.progress
//        appearance().trackTintColor = brand.track
//    }
//}
//
//extension UISlider {
//    static func apply(brand: Branding.Slider) {
//        appearance().setMinimumTrackImage(brand.minimum.image, for: [])
//        appearance().minimumTrackTintColor = brand.minimum.color
//
//        appearance().setMaximumTrackImage(brand.maximum.image, for: [])
//        appearance().maximumTrackTintColor = brand.maximum.color
//
//        appearance().setThumbImage(brand.thumb.image, for: [])
//        appearance().thumbTintColor = brand.thumb.color
//    }
//}
//
//extension UINavigationBar {
//    static func apply(brand: Branding.NavigationBar) {
//        appearance().tintColor = brand.tint
//        appearance().barTintColor = brand.barTint
//        appearance().barStyle = brand.style
//    }
//
//    var titleColor: UIColor? {
//        get {
//            if let attributes = self.titleTextAttributes {
//                return attributes[NSForegroundColorAttributeName] as? UIColor
//            }
//            return nil
//        }
//        set {
//            if let value = newValue {
//                self.titleTextAttributes = [NSForegroundColorAttributeName: value]
//            }
//        }
//    }
//
//    var titleFont: UIFont? {
//        get {
//            if let attributes = self.titleTextAttributes {
//                return attributes[NSFontAttributeName] as? UIFont
//            }
//            return nil
//        }
//        set {
//            if let value = newValue {
//                self.titleTextAttributes = [NSFontAttributeName: value]
//            }
//        }
//    }
//}

//extension UIView {
//    static func apply(brand: Branding.Background) {
////        appearance(whenContainedInInstancesOf: [UIViewController.self]).backgroundColor = brand.color
//    }
//}
//
//
//
//
//extension UITableView {
//    static func apply(brand: Branding.Menu) {
//        UITableView.appearance().backgroundColor = brand.background
//
//        MainMenuContentCell.apply(brand: brand)
//        MainMenuPushNavigationCell.apply(brand: brand)
//        MainMenuStaticDataCell.apply(brand: brand)
//    }
//}
//
//extension UICollectionView {
//    static func apply(brand: Branding) {
//
//    }
//}
//
//extension MainMenuContentCell {
//    static func apply(brand: Branding.Menu) {
//        appearance().contentView.backgroundColor = brand.cellBackground
//    }
//}
//
//extension MainMenuPushNavigationCell {
//    static func apply(brand: Branding.Menu) {
//        appearance().contentView.backgroundColor = brand.cellBackground
//    }
//}
//
//extension MainMenuStaticDataCell {
//    static func apply(brand: Branding.Menu) {
//        appearance().contentView.backgroundColor = brand.cellBackground
//    }
//}
//


//extension HeroPromotionCell {
//    static func apply(brand: Branding) {
//        appearance().backgroundColor =
//    }
//}

//extension Branding {
//    struct TextButton {
//        let text: UIColor
//        let disabled: UIColor
//    }
//
//    struct Progress {
//        let progress: UIColor
//        let track: UIColor
//    }
//
//    struct Slider {
//        let minimum: Track
//        let maximum: Track
//        let thumb: Track
//
//        struct Track {
//            let color: UIColor
//            let image: UIImage?
//
//            init(color: UIColor, image: UIImage? = nil) {
//                self.color = color
//                self.image = image
//            }
//        }
//    }
//
//    struct NavigationBar {
//        let tint: UIColor
//        let barTint: UIColor
//        let style: UIBarStyle = .black
//    }
//
//    struct Background {
//        let color: UIColor
//    }
//
//    struct Menu {
//        let background: UIColor
//        let cellBackground: UIColor
//        let headerDivider: UIColor
//    }
//}

struct Branding {
    struct ColorScheme {
        let accent: UIColor
        let text: Text
        let backdrop: Backdrop
        
        struct Text {
            let primary: UIColor
            let secondary: UIColor
        }
        
        struct Backdrop {
            let primary: UIColor
            let secondary: UIColor
        }
        
//        func apply() {
//            UIProgressView.apply(brand: progress)
//            UISlider.apply(brand: slider)
//            UINavigationBar.apply(brand: navigationBar)
//            UIView.apply(brand: background)
//            UITableView.apply(brand: menu)
//        }
//
//        var progress: Progress {
//            return Progress(progress: accent,
//                            track: text.secondary)
//        }
//
//        var slider: Slider {
//            return Slider(minimum: Slider.Track(color: accent),
//                          maximum: Slider.Track(color: text.secondary),
//                          thumb: Slider.Track(color: accent))
//        }
//
//        var navigationBar: NavigationBar {
//            return NavigationBar(tint: accent,
//                                 barTint: backdrop.primary)
//        }
//
//        var background: Background {
//            return Background(color: backdrop.primary)
//        }
//
//        var menu: Menu {
//            return Menu(background: backdrop.secondary,
//                        cellBackground: backdrop.secondary,
//                        headerDivider: backdrop.primary)
//        }
        
        static var `default`: ColorScheme {
            let text = Branding.ColorScheme.Text(primary: UIColor.redBeePaper,
                                                 secondary: UIColor.redBeeLightGrey)
            let backdrop = Branding.ColorScheme.Backdrop(primary: UIColor.redBeeBlack,
                                                         secondary: UIColor.redBeeCharcoal)
            let primary = UIColor.redBeeRed
//            let text = Branding.ColorScheme.Text(primary: UIColor.blue,
//                                                 secondary: UIColor.magenta)
//            let backdrop = Branding.ColorScheme.Backdrop(primary: UIColor.red,
//                                                         secondary: UIColor.orange)
//            let primary = UIColor.green
            
            return Branding.ColorScheme(accent: primary,
                                        text: text,
                                        backdrop: backdrop)
        }
        
        static var test: ColorScheme {
            let text = Branding.ColorScheme.Text(primary: UIColor.blue,
                                                 secondary: UIColor.magenta)
            let backdrop = Branding.ColorScheme.Backdrop(primary: UIColor.red,
                                                         secondary: UIColor.orange)
            let primary = UIColor.green
            
            return Branding.ColorScheme(accent: primary,
                                        text: text,
                                        backdrop: backdrop)
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

