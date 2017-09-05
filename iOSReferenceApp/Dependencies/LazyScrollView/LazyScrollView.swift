//
//  LazyScrollView.swift
//  iOSReferenceApp
//
//  Created by Hui Wang on 2017-05-12.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class LazyScrollView: UIScrollView, UIScrollViewDelegate {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
    }
    
}
