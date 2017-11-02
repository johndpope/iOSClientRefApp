//
//  EnvironmentSelectionViewController.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-01.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

import Exposure

class EnvironmentSelectionViewController: UIViewController {
    var viewModel: EnvironmentSelectionViewModel!
    
    @IBOutlet weak var environmentButton: UIButton!
    @IBOutlet weak var customerButton: UIButton!
    
    @IBOutlet weak var exposureUrlField: SkyFloatingLabelTextField!
    @IBOutlet weak var businessUnitField: SkyFloatingLabelTextField!
    @IBOutlet weak var customerField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBAction func continueAction(_ sender: UIButton) {
        applyEnvironment()
    }
    
    @IBAction func environmentAction(_ sender: UIButton) {
        displayEnvironmentSelection()
    }
    
    @IBAction func customerAction(_ sender: UIButton) {
        displayCustomerSelection()
    }
    
    @IBAction func textFieldValueChanged(_ sender: SkyFloatingLabelTextField) {
        if sender == exposureUrlField {
            updateError(exposureField: exposureUrlField)
        }
        else if sender == businessUnitField {
            updateError(businessUnitField: businessUnitField)
        }
        else if sender == customerField {
            updateError(customerField: customerField)
        }
        toggleContinueButton()
    }
    
    
    enum Segue: String {
        case environmentToLogin
    }
    
    override func viewDidLoad() {
        viewModel = EnvironmentSelectionViewModel()
        
        
        customerButton.setTitleColor(UIColor.darkGray, for: .disabled)
        customerButton.setTitleColor(UIColor.white, for: .normal)
        viewModel.updatedDefaultValues = { [weak self] (url, customer, businessUnit) in
            self?.exposureUrlField.text = url
            self?.customerField.text = customer
            self?.businessUnitField.text = businessUnit
            self?.toggleContinueButton()
            self?.toggleTextFields()
        }
        
        viewModel.updatedPresets = { [weak self] (environment, customer, enableCustomer) in
            self?.environmentButton.setTitle(environment, for: .normal)
            self?.customerButton.setTitle(customer, for: .normal)
            self?.customerButton.isEnabled = enableCustomer
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subscribe(keyboardNotifications: true)
        toggleContinueButton()
        
        customerButton.isEnabled = viewModel.selectedCustomer != nil || viewModel.selectedEnvironment != nil
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
}

extension EnvironmentSelectionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.environmentToLogin.rawValue, let destination = segue.destination as? LoginViewController {
            guard let environment = viewModel.selectedExposureEnvironment else { return }
            destination.viewModel = LoginViewModel(environment: environment,
                                                   loginMethod: viewModel.preferedLoginMethod)
//            destination.viewModel.prepareDynamicConfiguration{ config in
//
//            }
        }
    }
}

extension EnvironmentSelectionViewController {
    func applyEnvironment() {
        guard fieldsValid else { return }
        guard let environment = viewModel.selectedExposureEnvironment else { return }
        UserInfo.update(environment: environment)
        UserInfo.environment(loginMethod: viewModel.preferedLoginMethod.persistenceString)
        performSegue(withIdentifier: Segue.environmentToLogin.rawValue, sender: environment)
        // TODO: Preload Logo?
    }
    
    var fieldsValid: Bool {
        return valid(textField: exposureUrlField) &&
            valid(textField: businessUnitField) &&
            valid(textField: customerField)
    }
}

extension EnvironmentSelectionViewController: UITextFieldDelegate {
    func toggleTextFields() {
        updateError(exposureField: exposureUrlField)
        updateError(businessUnitField: businessUnitField)
        updateError(customerField: customerField)
    }
    
    fileprivate func valid(textField: SkyFloatingLabelTextField) -> Bool {
        if let text = textField.text {
            if textField == exposureUrlField {
                return text.contains("http")
            }
            else {
                return text.count > 2
            }
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
    
    fileprivate func toggleContinueButton() {
        continueButton.isEnabled = fieldsValid
        let color = fieldsValid ? UIColor.ericssonBlue : UIColor.lightGray
        continueButton.setTitleColor(color, for: .normal)
    }
    
    fileprivate func updateError(exposureField textField: SkyFloatingLabelTextField) {
        if shouldDisplayError(textField: textField) { textField.errorMessage = "Invalid url" }
        else { textField.errorMessage = "" }
    }
    
    fileprivate func updateError(businessUnitField textField: SkyFloatingLabelTextField) {
        if shouldDisplayError(textField: textField) { textField.errorMessage = "Business Unit too short" }
        else {  textField.errorMessage = "" }
    }
    
    fileprivate func updateError(customerField textField: SkyFloatingLabelTextField) {
        if shouldDisplayError(textField: textField) { textField.errorMessage = "Customer too short" }
        else {  textField.errorMessage = "" }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == exposureUrlField {
            businessUnitField.becomeFirstResponder()
        } else if textField == businessUnitField {
            customerField.becomeFirstResponder()
        }
        else if textField == customerField {
            applyEnvironment()
        }
        
        return true
    }
}

extension EnvironmentSelectionViewController {
    func displayEnvironmentSelection() {
        let picker = McPicker(data: [viewModel.environmentSelections])
        picker.selectionIndicatorColor = UIColor.ericssonBlue
        picker.toolBarButtonsColor = UIColor.ericssonBlue
        picker.show{ [weak self] selections in
            guard let weakSelf = self else { return }
            if let title = selections[0] {
                weakSelf.viewModel.select(environment: title)
            }
        }
    }
    
    func displayCustomerSelection() {
        guard let environmentIndex = viewModel.selectedEnvironment else { return }
        let picker = McPicker(data: [viewModel.customerSelections(index: environmentIndex)])
        picker.selectionIndicatorColor = UIColor.ericssonBlue
        picker.toolBarButtonsColor = UIColor.ericssonBlue
        picker.show{ [weak self] selections in
            guard let weakSelf = self else { return }
            if let title = selections[0] {
                weakSelf.viewModel.select(customer: title)
            }
        }
    }
}
