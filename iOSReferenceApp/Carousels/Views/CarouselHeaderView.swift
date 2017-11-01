//
//  CarouselHeaderView.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-22.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class CarouselHeaderView: UICollectionReusableView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var editorialText: UILabel!
    
    @IBOutlet weak var leadingInset: NSLayoutConstraint!
    @IBOutlet weak var trailingInset: NSLayoutConstraint!
    
    func reset() {
        title.text = nil
        editorialText.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with carousel: CarouselEditorial) {
        reset()
        title.text = carousel.headerViewModel?.title?.uppercased()
        editorialText.text = carousel.headerViewModel?.text
//        if let text = carousel.headerViewModel?.text {
//            editorialText.isHidden = false
//            editorialText.text = text
//        }
//        else {
//            editorialText.isHidden = true
//        }
        leadingInset.constant = carousel.headerViewModel?.sideInset ?? 0
    }
}
