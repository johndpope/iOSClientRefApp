//
//  Extensions.swift
//  iOSReferenceApp
//
//  Created by Hui Wang on 2017-05-15.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

// MARK:- Message UI
// Show message on screen.
extension UIViewController {
    func showMessage(title: String, message: String) {
        #if DEBUG
            print(message)
        #endif
        let alertController = UIAlertController(title: title, message: message, preferredStyle:UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel)
        { action -> Void in
            
        })
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK:- Keyboard moving
// Move UIView up when the keyboard appears.
extension UIViewController {
    
    // Keyboard dismissal
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func keyboardShow(notification: Notification) {
        if self.view.frame.origin.y >= 0 {
            setViewMovedUp(movedUp: true, notification: notification)
        }
    }
    
    func keyboardHide(notification: Notification) {
        if self.view.frame.origin.y < 0 {
            setViewMovedUp(movedUp: false, notification: notification)
        }
    }
    
    func subscribe(keyboardNotifications subscribtion: Bool) {
        if subscribtion {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        }
        else {
            NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        }
    }
    
    func setViewMovedUp(movedUp: Bool, notification: Notification) {
        let offset = notification.keyboardAnimationFrame.endFrame.height
//        print(movedUp ? "UP  ":"DOWN",notification.keyboardAnimationFrame.endFrame, notification.keyboardAnimationFrame.beginFrame, self.view.frame.origin.y)
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = (movedUp ? -offset : 0)
        }
    }
}

// MARK:- Screen orientation
// Keep all screens portrait except Player viewcontroller.
extension UINavigationController {
    
    // Keep all screens portrait except Player viewcontroller.
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
}

// MARK:- String handling
extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "^[A-Z0-9a-z._%+-]{1,}[@]{1}[A-Za-z0-9.-]{1,}[.]{1}[A-Za-z]{1,}$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
