//
//  CarouselFooterView.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-22.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class CarouselFooterView: UICollectionReusableView {

    var fadeColor: UIColor = UIColor.white
    var originalColor: UIColor = UIColor.black
    var roundness: CGFloat = 20
    
    private var gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var footerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Necessary in layoutSubviews to get the proper frame size.
    }
    
    func setupFade() {
        let colors = [fadeColor.cgColor, originalColor.cgColor]
        gradientLayer.colors = colors
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.frame = bounds
        
        footerView.layer.backgroundColor = originalColor.cgColor
        footerView.layer.cornerRadius = roundness
        footerView.layer.shadowColor = UIColor.black.cgColor
        footerView.layer.shadowOpacity = 1
        footerView.layer.shadowOffset = CGSize.zero
        footerView.layer.shadowRadius = 3
        footerView.layer.shadowPath = UIBezierPath(roundedRect: footerView.bounds, cornerRadius: roundness).cgPath
    }
    
//    // Helper to return the main layer as CAGradientLayer
//    var gradientLayer: CAGradientLayer {
//        return layer as! CAGradientLayer
//    }
}
