//
//  CarouselFooterView.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-22.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class CarouselFooterView: UICollectionReusableView {

    var fadeColor: UIColor = UIColor("18181A")
    var originalColor: UIColor = UIColor("0C0E0F")
    var roundness: CGFloat = 20
    
    private var gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var footerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupFade() {
        let colors = [fadeColor.cgColor, originalColor.cgColor]
        gradientLayer.colors = colors
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.frame = bounds
        
        let fadeLayer = CAShapeLayer()
        fadeLayer.path = UIBezierPath(rect: footerView.bounds).cgPath
//        fadeLayer.path = UIBezierPath(roundedRect: footerView.bounds, cornerRadius: roundness).cgPath
        fadeLayer.backgroundColor = originalColor.cgColor
        footerView.layer.insertSublayer(fadeLayer, at: 0)
        
        let shadowLayer = CALayer()
        shadowLayer.cornerRadius = roundness
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowOffset = CGSize.zero
        shadowLayer.shadowRadius = 3
        shadowLayer.shadowPath = UIBezierPath(rect: footerView.bounds).cgPath
//        shadowLayer.shadowPath = UIBezierPath(roundedRect: footerView.bounds, cornerRadius: roundness).cgPath
        footerView.layer.insertSublayer(shadowLayer, at: 0)
        
        
    }
    
//    // Helper to return the main layer as CAGradientLayer
//    var gradientLayer: CAGradientLayer {
//        return layer as! CAGradientLayer
//    }
}
