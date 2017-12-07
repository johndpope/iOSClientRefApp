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
    
    var updatedDefaultValues: (_ baseUrl: String?, _ customer: String?, _ businessUnit: String?, _ usesMfa: Bool?) -> Void = { _,_,_,_ in }
    var updatedPresets: (_ environment: String, _ customer: String, _ enableCustomer: Bool) -> Void = { _, _, _ in }
    
    init() {
        environments = EnvironmentConfig.preconfigured(files:["environments"])
        
    }
    
    func reset() {
        selectedEnvironment = nil
        selectedCustomer = nil
        
        updatedPresets("Environment", "Customer", false)
        updatedDefaultValues(nil, nil, nil, nil)
    }
    
    func select(environment: String) {
        guard let index = environmentSelections.index(of: environment) else { return }
        selectedEnvironment = index
        selectedCustomer = nil
        
        updatedPresets(environmentSelections[index], "Customer", true)
        updatedDefaultValues(environments[index].url, nil, nil, nil)
        
        if let preselectedCustomer = customerSelections(index: index).first {
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
                             environments[environmentIndex].customers[index].businessUnit,
                             environments[environmentIndex].customers[index].usesMfa)
    }
}
