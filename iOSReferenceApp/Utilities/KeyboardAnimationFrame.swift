//
//  KeyboardAnimationFrame.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-03-27.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

import UIKit

struct KeyboardAnimationFrame {
    private let userInfo: [AnyHashable: Any]
    init(notification: Notification) {
        userInfo = notification.userInfo ?? [:]
    }
    
    var beginFrame: CGRect {
        return (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
    }
    
    var endFrame: CGRect {
        return (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
    }
    
    var belongsToCurrentApp: Bool {
        if #available(iOS 9.0, *) {
            return (userInfo[UIKeyboardIsLocalUserInfoKey] as? Bool) ?? true
        } else {
            return true
        }
    }
    
    var animationDuration: Double {
        return (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
    }
    
    var animationCurve: UIViewAnimationCurve {
        guard let value = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int else { return .easeInOut }
        return UIViewAnimationCurve(rawValue: value) ?? .easeInOut
    }
    
    var animationOptions: UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: UInt(animationCurve.rawValue << 16))
    }
}
