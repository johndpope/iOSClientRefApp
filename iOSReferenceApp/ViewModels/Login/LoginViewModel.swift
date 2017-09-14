//
//  LoginViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-03-27.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class LoginViewModel {
    fileprivate(set) var environments: [EnvironmentConfig] = []
    var environmentsTitleArray: [String] = []
    var customersTitleArray: [String] = []
    fileprivate var selectedEnvironmentIndex: Int = 0
    fileprivate var selectedCustomerIndex: Int = 0
    
    init() {
        environments = EnvironmentConfig.preconfigured(files:["environments"])
        
        loadData()
    }
}

// MARK:- Data handling
extension LoginViewModel {
    
    func loadData() {
        environmentsTitleArray.removeAll()

        print(environments)
        for environment in environments {
            print(environment)
            environmentsTitleArray.append(environment.pickerModelTitle)
        }
    }
    
    func selectedEnvironment(title: String) {
        if let index = environmentsTitleArray.index(of: title) {
            self.selectedEnvironmentIndex = index
            resetCustomer()
            
            if let customers = getSelectedEnvironmentConfig()?.customers {
                for customer in customers {
                    customersTitleArray.append(customer.pickerModelTitle)
                }
            }
        }
    }
    
    func selectedCustomer(title: String) {
        if let index = customersTitleArray.index(of: title) {
            self.selectedCustomerIndex = index
        }
    }
    
    private func resetCustomer() {
        self.customersTitleArray.removeAll()
        self.selectedCustomerIndex = 0
    }
    
    func getSelectedEnvironmentConfig() -> EnvironmentConfig? {
        return environments.count > 0 ? environments[self.selectedEnvironmentIndex] : nil
    }
    
    func getSelectedCustomerConfig() -> CustomerConfig? {
        if let environment = getSelectedEnvironmentConfig() {
            return environment.customers.count > 0 ? environment.customers[self.selectedCustomerIndex] : nil
        }
        return nil
    }
    
    func anonymous(callback: @escaping (ExposureResponse<SessionToken>) -> Void) {
        Authenticate(environment: selectedExposureEnvironment()!)
            .anonymous()
            .request()
            .validate(statusCode: 200..<299)
            .response{ (response: ExposureResponse<SessionToken>) in
                callback(response)
        }
    }
    
    func login(exposureUsername: String, exposurePassword: String, callback: @escaping (ExposureResponse<Credentials>) -> Void) {
        Authenticate(environment: selectedExposureEnvironment()!)
            .login(username: exposureUsername,
                   password: exposurePassword)
            .request()
            .validate(statusCode: 200..<299)
            .response { (dataResponse: ExposureResponse<Credentials>) in
                callback(dataResponse)
        }
    }
    
    func twoFactor(exposureUsername: String, exposurePassword: String, mfa: String, callback: @escaping (ExposureResponse<Credentials>) -> Void) {
        Authenticate(environment: selectedExposureEnvironment()!)
            .twoFactor(username: exposureUsername,
                       password: exposurePassword,
                       twoFactor: mfa)
            .request()
            .validate(statusCode: 200..<299)
            .response { (dataResponse: ExposureResponse<Credentials>) in
                callback(dataResponse)
        }
    }
}

// MARK: - Exposure Integration
/// Changes and customizations to the username and password should be stored here in the viewmodel
extension LoginViewModel {
    func selectedExposureEnvironment() -> Environment? {
        if let environment = getSelectedEnvironmentConfig(), let customerConfig = getSelectedCustomerConfig() {
            return Environment(baseUrl: environment.url, customer: customerConfig.customer, businessUnit: customerConfig.businessUnit)
        } else {
            return nil
        }
    }
}
