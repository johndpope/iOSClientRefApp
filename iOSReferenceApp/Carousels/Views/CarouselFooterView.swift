//
//  CarouselFooterView.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-22.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class CarouselFooterView: UICollectionReusableView {

    var fadeColor: UIColor = UIColor(red: 0.133, green: 0.133, blue: 0.141, alpha: 1)
    var originalColor: UIColor = UIColor(red: 0.047, green: 0.055, blue: 0.059, alpha: 1)
    var roundness: CGFloat = 20
    
    @IBOutlet weak var fadeView: UIView!
    @IBOutlet weak var gradientView: UIView!
    private var gradientLayer = CAGradientLayer()
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        UIColor(red: 0.047, green: 0.055, blue: 0.059, alpha: 1)
//        UIColor(red: 0.094, green: 0.094, blue: 0.102, alpha: 1)
//        UIColor(red: 0.133, green: 0.133, blue: 0.141, alpha: 1)
    }
    
    func setupFade() {
        let colors = [fadeColor.cgColor, originalColor.cgColor]
        gradientLayer.colors = colors
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = gradientView.bounds
        
        gradientView.layer.addSublayer(gradientLayer)
        
        let overFadeLayer = CAShapeLayer()
        overFadeLayer.path = UIBezierPath(rect: fadeView.bounds).cgPath
        overFadeLayer.fillColor = originalColor.cgColor
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
    
//    // Helper to return the main layer as CAGradientLayer
//    var gradientLayer: CAGradientLayer {
//        return layer as! CAGradientLayer
//    }
}
