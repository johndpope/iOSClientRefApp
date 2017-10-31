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
        backgroundColor = UIColor.green
        reset()
        title.text = carousel.headerViewModel?.title
        editorialText.text = carousel.headerViewModel?.text
        leadingInset.constant = carousel.headerViewModel?.sideInset ?? 0
//        reset()
//        title.text = carousel.title?.uppercased()
//        editorialText.text = carousel.text
//        leadingInset.constant = carousel.sideInset
    }
}
