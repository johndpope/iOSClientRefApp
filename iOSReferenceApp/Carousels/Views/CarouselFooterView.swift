//
//  CarouselFooterView.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-22.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class CarouselFooterView: UICollectionReusableView {
    var roundness: CGFloat = 20
    
    @IBOutlet weak var fadeView: UIView!
    @IBOutlet weak var gradientView: UIView!
    fileprivate var gradientLayer = CAGradientLayer()
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension CarouselFooterView: DynamicAppearance {
    func apply(brand: Branding.ColorScheme) {
        backgroundColor = brand.backdrop.primary
        
        gradientLayer.colors = brand.fade.colors
        
        gradientLayer.startPoint = brand.fade.start
        gradientLayer.endPoint = brand.fade.end
        gradientLayer.frame = gradientView.bounds
        
        gradientView.layer.addSublayer(gradientLayer)
        
        let overFadeLayer = CAShapeLayer()
        overFadeLayer.path = UIBezierPath(rect: fadeView.bounds).cgPath
        overFadeLayer.fillColor = (brand.fade.colors.last ?? UIColor.black).cgColor
        fadeView.layer.addSublayer(overFadeLayer)

        let shadowLayer = CALayer()
//        shadowLayer.cornerRadius = roundness
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowOffset = CGSize.zero
        shadowLayer.shadowRadius = 3
        shadowLayer.shadowPath = UIBezierPath(rect: fadeView.bounds).cgPath
//        shadowLayer.shadowPath = UIBezierPath(roundedRect: footerView.bounds, cornerRadius: roundness).cgPath
        fadeView.layer.insertSublayer(shadowLayer, at: 0)
        
        
    }
}
