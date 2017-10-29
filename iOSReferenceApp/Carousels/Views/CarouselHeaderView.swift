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
        title.text = carousel.title?.uppercased()
        editorialText.text = carousel.text
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
}
