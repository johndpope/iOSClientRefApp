//
//  LoginViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-03-27.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit
import Exposure

class OldLoginViewController: UIViewController {

    let viewmodel = LoginViewModel()
    var app: AppDelegate!
    
    // MARK: UI
    @IBOutlet weak var environmentButton: UIButton!
    @IBOutlet weak var customerButton: UIButton!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var anonymousSwitch: UISwitch!
    fileprivate(set) var twoFactorRequired = false
    
    @IBAction func environmentButtonClick(_ sender: UIButton) {
        openEnvironmentSelection()
    }
    
    @IBAction func customerButtonClick(_ sender: UIButton) {
        openCustomerSelection()
    }
    
    @IBAction func loginButtonClick(_ sender: UIButton) {
        login()
    }
    
    func login() {
        guard isValidInfo() else { return }
        UserInfo.clear()
        UserInfo.update(environment: viewmodel.selectedExposureEnvironment()!) // Todo: Do not use Implicit unwrapped optionals
        
        if anonymousSwitch.isOn {
            handleAnonymousLogin()
        } else {
            if twoFactorRequired {
                handleTwoFactorLogin()
            }
            else {
                handleLogin()
            }
        }
    }
    
    // MARK: Anonymous
    fileprivate func handleAnonymousLogin() {
        ProgressIndicatorUtil.shared.show(parentView: self.view)
        viewmodel.anonymous(callback: { (response) in
            defer {
                ProgressIndicatorUtil.shared.hide()
            }
            
            if let error = response.error {
                self.showMessage(title: "Login Error", message: error.localizedDescription)
                return
            }
            
            if let sessionToken = response.value {
                UserInfo.update(sessionToken: sessionToken)
                self.performSegue(withIdentifier: Constants.Storyboard.homeSegue, sender: sessionToken)
            }
        })
    }
    
    @IBAction func anonymousSwitchClick(_ sender: UISwitch) {
        if sender.isOn {
            if self.environmentButton.titleLabel?.text != StringsUtil.shared.getString(key: Constants.Strings.environment) {
                self.toggleLoginButton(enabled: true)
            } else {
                self.toggleLoginButton(enabled: false)
            }
        } else {
            if self.environmentButton.titleLabel?.text == StringsUtil.shared.getString(key: Constants.Strings.environment) || self.customerButton.titleLabel?.text == StringsUtil.shared.getString(key: Constants.Strings.customer) {
                self.toggleLoginButton(enabled: false)
            }
        }
    }
    
    // MARK: Login
    fileprivate func handleLogin() {
        ProgressIndicatorUtil.shared.show(parentView: self.view)
        viewmodel.login(exposureUsername: usernameTextField.text!, exposurePassword: passwordTextField.text!, callback: { (response) in
            defer {
                ProgressIndicatorUtil.shared.hide()
            }
            
            if let error = response.error {
                self.showMessage(title: "Login Error", message: error.localizedDescription)
                return
            }
            
            if let credentials = response.value {
                UserInfo.update(credentials: credentials)
                self.performSegue(withIdentifier: Segue.masterView.rawValue, sender: credentials)
            }
        })
    }
    
    
    enum Segue: String {
        case masterView = "masterView"
    }
    
    // MARK: TwoFactor
    fileprivate func handleTwoFactorLogin() {
        let alertController = UIAlertController(title: "Two Factor Authentication", message: "Please provide an MFA token", preferredStyle: .alert)
        
        // Confirm
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [unowned self] action in
            ProgressIndicatorUtil.shared.show(parentView: self.view)
            if let mfa = alertController.textFields?.first?.text {
                self.viewmodel
                    .twoFactor(exposureUsername: self.usernameTextField.text!,
                               exposurePassword: self.passwordTextField.text!,
                               mfa: mfa) { response in
                                defer {
                                    ProgressIndicatorUtil.shared.hide()
                                }
                                
                                if let error = response.error {
                                    self.showMessage(title: "Login Error", message: error.localizedDescription)
                                    return
                                }
                                
                                if let credentials = response.value {
                                    UserInfo.update(credentials: credentials)
                                    self.performSegue(withIdentifier: Segue.masterView.rawValue, sender: credentials)
                                }
                }
            }
        }
        
        // Cancel
        let cancelAciton = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addTextField{ textfield in
            textfield.placeholder = "MFA"
            textfield.keyboardType = UIKeyboardType.numberPad
        }
        
        alertController.addAction(cancelAciton)
        alertController.addAction(confirmAction)
        
        present(alertController, animated: true)
    }
    
    // MARK: Basics
    override func viewDidLoad() {
        super.viewDidLoad()
        app = UIApplication.shared.delegate as! AppDelegate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subscribe(keyboardNotifications: true)
    }
    
    override func viewDidDisappear(_ animated: Bool){
        super.viewDidDisappear(animated)
        subscribe(keyboardNotifications: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Update UI
extension OldLoginViewController {
    
    func toggleLoginButton(enabled: Bool) {
        loginButton.isEnabled = enabled
        loginButton.backgroundColor = enabled ? UIColor.ericssonBlue : UIColor.lightGray
    }
}

// MARK: - Open PickerView
extension OldLoginViewController {
    
    func openEnvironmentSelection() {
        let picker = McPicker(data:[viewmodel.environmentsTitleArray])
        picker.selectionIndicatorColor = UIColor.ericssonBlue
        picker.toolBarButtonsColor = UIColor.ericssonBlue
        picker.show(doneHandler: { selections in
            
            if let title = selections[0] {
                self.viewmodel.selectedEnvironment(title: title)
                if let pickerTitle = self.viewmodel.getSelectedEnvironmentConfig()?.pickerModelTitle {
                    self.environmentButton.setTitle(pickerTitle, for: .normal)
                    if ((self.viewmodel.getSelectedEnvironmentConfig()?.customers.count)! > 0) {
                        if let customerPickerTitle = self.viewmodel.getSelectedCustomerConfig()?.pickerModelTitle {
                            self.customerButton.setTitle(customerPickerTitle, for: .normal)
                            self.customerButton.isEnabled = true
                            self.toggleLoginButton(enabled: true)
                            self.handlePresets(customer: self.viewmodel.getSelectedCustomerConfig())
                        }
                    } else {
                        self.customerButton.setTitle(StringsUtil.shared.getString(key: Constants.Strings.customer), for: .normal)
                        self.customerButton.isEnabled = false
                        self.toggleLoginButton(enabled: false)
                        self.usernameTextField.text = ""
                        self.passwordTextField.text = ""
                    }
                }
            }
        })
    }
    
    private func handlePresets(customer: CustomerConfig?) {
        usernameTextField.text = ""
        passwordTextField.text = ""
        anonymousSwitch.isOn = false
        twoFactorRequired = false
        if let method = customer?.presetMethod {
            switch method {
            case .login(let username, let password, let mfa):
                usernameTextField.text = username
                passwordTextField.text = password
                twoFactorRequired = mfa
            case .anonymous:
                anonymousSwitch.isOn = true
            }
        }
    }
    
    func openCustomerSelection() {
        let picker = McPicker(data:[viewmodel.customersTitleArray])
        picker.selectionIndicatorColor = UIColor.ericssonBlue
        picker.toolBarButtonsColor = UIColor.ericssonBlue
        picker.show(doneHandler: { selections in
            
            if let title = selections[0] {
                self.viewmodel.selectedCustomer(title: title)
                if let pickerTitle = self.viewmodel.getSelectedCustomerConfig()?.pickerModelTitle {
                    self.customerButton.setTitle(pickerTitle, for: .normal)
                    self.toggleLoginButton(enabled: true)
                    
                    self.handlePresets(customer: self.viewmodel.getSelectedCustomerConfig())
                } else {
                    self.customerButton.setTitle(StringsUtil.shared.getString(key: Constants.Strings.customer), for: .normal)
                    self.toggleLoginButton(enabled: false)
                    self.usernameTextField.text = ""
                    self.passwordTextField.text = ""
                }
            }
        })
    }
}

// MARK: - Text Input Management
extension OldLoginViewController: UITextFieldDelegate {
    
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

// MARK: - Info validation
extension OldLoginViewController {
    func isValidInfo() -> Bool {
        
        if self.viewmodel.selectedExposureEnvironment() == nil {
            self.showMessage(title: StringsUtil.shared.getString(key: Constants.Strings.error), message: StringsUtil.shared.getString(key: Constants.Strings.Error.invalidEnvironment))
            return false
        }
        
        if self.viewmodel.getSelectedCustomerConfig() == nil {
            self.showMessage(title: StringsUtil.shared.getString(key: Constants.Strings.error), message: StringsUtil.shared.getString(key: Constants.Strings.Error.invalidCustomer))
            return false
        }
        
        if !anonymousSwitch.isOn {
            if usernameTextField.text!.isEmpty {
                self.showMessage(title: StringsUtil.shared.getString(key: Constants.Strings.error), message: StringsUtil.shared.getString(key: Constants.Strings.Error.invalidUsername))
                return false
            }
            
            if passwordTextField.text!.isEmpty {
                self.showMessage(title: StringsUtil.shared.getString(key: Constants.Strings.error), message: StringsUtil.shared.getString(key: Constants.Strings.Error.invalidPassword))
                return false
            }
        }
        
        return true
    }
}
