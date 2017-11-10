//
//  EnvironmentSelectionViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-01.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

class EnvironmentSelectionViewModel {
    fileprivate(set) var environments: [EnvironmentConfig] = []
    
    fileprivate(set) var selectedEnvironment: Int?
    lazy var environmentSelections: [String] = { [weak self] in
        return self?.environments.map{ $0.pickerModelTitle } ?? []
    }()
    
    fileprivate(set) var selectedCustomer: Int?
    func customerSelections(index: Int) -> [String] {
        return environments[index].customers.map{ $0.pickerModelTitle }
    }
    
    var updatedDefaultValues: (_ baseUrl: String?, _ customer: String?, _ businessUnit: String?) -> Void = { _, _, _ in }
    var updatedPresets: (_ environment: String, _ customer: String, _ enableCustomer: Bool) -> Void = { _, _, _ in }
    
    init() {
        environments = EnvironmentConfig.preconfigured(files:["environments"])
        
    }
    
    func reset() {
        selectedEnvironment = nil
        selectedCustomer = nil
        
        updatedPresets("Environment", "Customer", false)
        updatedDefaultValues(nil, nil, nil)
    }
    
    func select(environment: String) {
        guard let index = environmentSelections.index(of: environment) else { return }
        selectedEnvironment = index
        selectedCustomer = nil
        
        updatedPresets(environmentSelections[index], "Customer", true)
        updatedDefaultValues(environments[index].url, nil, nil)
        
        if let preselectedCustomer = customerSelections(index: 0).first {
            select(customer: preselectedCustomer)
        }
    }
    
    func select(customer: String) {
        guard let environmentIndex = selectedEnvironment else { return }
        guard let index = customerSelections(index: environmentIndex).index(of: customer) else { return }
        selectedCustomer = index
        
        updatedPresets(environmentSelections[environmentIndex],
                       customerSelections(index: environmentIndex)[index],
                       true)
        updatedDefaultValues(environments[index].url,
                             environments[environmentIndex].customers[index].customer,
                             environments[environmentIndex].customers[index].businessUnit)
    }
    
    var preferedLoginMethod: CustomerConfig.PresetMethod {
        guard let environmentIndex = selectedEnvironment, let customerIndex = selectedCustomer else { return .login(username: "", password: "", mfa: false) }
        guard let presetMethod = environments[environmentIndex].customers[customerIndex].presetMethod else { return .login(username: "", password: "", mfa: false) }
        return presetMethod
    }
    
    var selectedExposureEnvironment: Environment? {
        guard let environmentIndex = selectedEnvironment, let customerIndex = selectedCustomer else { return nil }
        let environmentConfig = environments[environmentIndex]
        let customerConfig = environmentConfig.customers[customerIndex]
        return Environment(baseUrl: environmentConfig.url,
                           customer: customerConfig.customer,
                           businessUnit: customerConfig.businessUnit)
    }
}
