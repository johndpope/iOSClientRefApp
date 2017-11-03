//
//  LoginViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-02.
//  Copyright © 2017 emp. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    enum Segue: String {
        case loginToMaster
    }
    
    var viewModel: LoginViewModel!
    var dynamicCustomerConfig: DynamicCustomerConfig?
    
    @IBOutlet weak var serviceLogo: UIImageView!
    
    @IBOutlet weak var loginStackView: UIStackView!
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
        UserInfo.clear()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        login()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLoginControls()
        
        if let conf = dynamicCustomerConfig {
            process(dynamicCustomerConfig: conf)
        }
        else {
            ApplicationConfig(environment: viewModel.environment)
                .fetchFile(fileName: "main.json") { [weak self] file in
                    if let jsonData = file?.config, let dynamicConfig = DynamicCustomerConfig(json: jsonData) {
                        self?.dynamicCustomerConfig = dynamicConfig
                        self?.process(dynamicCustomerConfig: dynamicConfig)
                    }
            }
        }
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
    
    fileprivate func process(dynamicCustomerConfig: DynamicCustomerConfig) {
        guard let logoString = dynamicCustomerConfig.logoUrl, let logoUrl = URL(string: logoString) else { return }
        serviceLogo
            .kf
            .setImage(with: logoUrl,
                      options: viewModel.logoImageOptions(size: serviceLogo.bounds.size)) { [weak self] (image, error, _, _) in
                        
        }
    }
}

extension LoginViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.loginToMaster.rawValue, let destination = segue.destination as? MasterViewController {
            if let conf = dynamicCustomerConfig {
                destination.dynamicCustomerConfig = conf
            }
        }
    }
}

extension LoginViewController {
    func configureLoginControls() {
        switch viewModel.loginMethod {
        case .anonymous:
            usernameTextField.isHidden = true
            passwordTextField.isHidden = true
        case .login(username: let username, password: let password, mfa: _):
            usernameTextField.isHidden = false
            passwordTextField.isHidden = false
            usernameTextField.text = username
            passwordTextField.text = password
        }
        toggleLoginButton()
    }
}

extension LoginViewController {
    func login() {
        guard fieldsValid else { return }
        switch viewModel.loginMethod {
        case .anonymous: handleAnonymousLogin()
        case .login(username: _, password: _, mfa: let mfa): mfa ? handleTwoFactorLogin() : handleLogin()
        }
    }
    
    // MARK: Anonymous
    fileprivate func handleAnonymousLogin() {
        ProgressIndicatorUtil.shared.show(parentView: self.view)
        viewModel.anonymous(callback: { (response) in
            defer {
                ProgressIndicatorUtil.shared.hide()
            }
            
            if let error = response.error {
                self.showMessage(title: "Login Error", message: error.localizedDescription)
                return
            }
            
            if let sessionToken = response.value {
                UserInfo.update(sessionToken: sessionToken)
                self.performSegue(withIdentifier: Segue.loginToMaster.rawValue, sender: sessionToken)
            }
        })
    }
    // MARK: Login
    fileprivate func handleLogin() {
        ProgressIndicatorUtil.shared.show(parentView: self.view)
        viewModel.login(exposureUsername: usernameTextField.text!, exposurePassword: passwordTextField.text!, callback: { (response) in
            defer {
                ProgressIndicatorUtil.shared.hide()
            }
            
            if let error = response.error {
                self.showMessage(title: "Login Error", message: error.localizedDescription)
                return
            }
            
            if let credentials = response.value {
                UserInfo.update(credentials: credentials)
                self.performSegue(withIdentifier: Segue.loginToMaster.rawValue, sender: credentials)
            }
        })
    }
    
    // MARK: TwoFactor
    fileprivate func handleTwoFactorLogin() {
        let alertController = UIAlertController(title: "Two Factor Authentication", message: "Please provide an MFA token", preferredStyle: .alert)
        
        // Confirm
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] action in
            guard let weakSelf = self else { return }
            ProgressIndicatorUtil.shared.show(parentView: weakSelf.view)
            if let mfa = alertController.textFields?.first?.text {
                weakSelf.viewModel
                    .twoFactor(exposureUsername: weakSelf.usernameTextField.text!,
                               exposurePassword: weakSelf.passwordTextField.text!,
                               mfa: mfa) { response in
                                defer {
                                    ProgressIndicatorUtil.shared.hide()
                                }
                                
                                if let error = response.error {
                                    weakSelf.showMessage(title: "Login Error", message: error.localizedDescription)
                                    return
                                }
                                
                                if let credentials = response.value {
                                    UserInfo.update(credentials: credentials)
                                    weakSelf.performSegue(withIdentifier: Segue.loginToMaster.rawValue, sender: credentials)
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
