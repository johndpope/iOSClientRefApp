//
//  LoginViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-02.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var serviceLogo: UIImageView!
    
    @IBOutlet weak var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func textFieldValueChanged(_ sender: SkyFloatingLabelTextField) {
        if sender == usernameTextField {
            updateError(username: usernameTextField)
        }
        else if sender == passwordTextField {
            updateError(password: passwordTextField)
        }
        toggleLoginButton()
    }
    
    @IBAction func changeEnvironmentAction(_ sender: UIButton) {
        print(#function)
        UserInfo.clear()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        login()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidDisappear(_ animated: Bool){
        super.viewDidDisappear(animated)
        subscribe(keyboardNotifications: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribe(keyboardNotifications: true)
        toggleLoginButton()
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}

extension LoginViewController {
    func login() {
        
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    var fieldsValid: Bool {
        return valid(textField: usernameTextField) &&
            valid(textField: passwordTextField)
    }
    
    func toggleTextFields() {
        updateError(username: usernameTextField)
        updateError(password: passwordTextField)
    }
    
    fileprivate func valid(textField: SkyFloatingLabelTextField) -> Bool {
        if let text = textField.text {
            return text.count > 2
        }
        return false
    }
    
    fileprivate func shouldDisplayError(textField: SkyFloatingLabelTextField) -> Bool {
        if let text = textField.text {
            if text == "" { return false }
            else { return !valid(textField: textField) }
        }
        return true
    }
    
    fileprivate func toggleLoginButton() {
        loginButton.isEnabled = fieldsValid
        let color = fieldsValid ? UIColor.ericssonBlue : UIColor.lightGray
        loginButton.setTitleColor(color, for: .normal)
    }
    
    fileprivate func updateError(username textField: SkyFloatingLabelTextField) {
        if shouldDisplayError(textField: textField) { textField.errorMessage = "Username too short" }
        else { textField.errorMessage = "" }
    }
    
    
    fileprivate func updateError(password textField: SkyFloatingLabelTextField) {
        if shouldDisplayError(textField: textField) { textField.errorMessage = "Password too short" }
        else {  textField.errorMessage = "" }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            login()
        }
        
        return true
    }
}
