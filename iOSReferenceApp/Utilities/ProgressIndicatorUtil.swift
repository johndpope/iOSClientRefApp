//
//  ProgressIndicatorUtil.swift
//  iOSReferenceApp
//
//  Created by Hui Wang on 2017-05-16.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class ProgressIndicatorUtil {
    //    Global: let PROGRESS_INDICATOR_UTIL = ProgressIndicatorUtil.sharedInstance
    
    class var sharedInstance : ProgressIndicatorUtil {
        struct Static {
            static let instance : ProgressIndicatorUtil = ProgressIndicatorUtil()
        }
        return Static.instance
    }
    
    init(){
    }
    
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var tapGesture:UITapGestureRecognizer?
    
    func show(parentView: UIView) {
        container.frame = parentView.frame
        container.center = parentView.center
        container.backgroundColor = UIColor(hex6: 0xffffff, alpha: 0.05)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = parentView.center
        loadingView.backgroundColor = UIColor(hex6: 0x000000, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2,y :loadingView.frame.size.height / 2)
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        parentView.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    func hide() {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
        if let gesture = self.tapGesture {
            container.removeGestureRecognizer(gesture)
        }
    }
    
    func setCancelable(cancelable: Bool) {
        if cancelable {
            self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(fingerTap(_:)))
            container.addGestureRecognizer(tapGesture!)
        }
    }
    
    @objc func fingerTap(_ sender: UITapGestureRecognizer) {
        self.hide()
    }
}
