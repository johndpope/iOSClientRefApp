//
//  Notifications+KeyboardAnimationFrame.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-03-27.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

extension Notification {
    var keyboardAnimationFrame: KeyboardAnimationFrame {
        return KeyboardAnimationFrame(notification: self)
    }
}
