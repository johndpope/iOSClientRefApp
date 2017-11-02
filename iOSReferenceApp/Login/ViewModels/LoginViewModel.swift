//
//  LoginViewModel.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-11-02.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure
import Kingfisher

class LoginViewModel {
    let environment: Environment
    var loginMethod: CustomerConfig.PresetMethod
    fileprivate var applicationConfig: ApplicationConfig?
    fileprivate var dynamicCustomerConfig: DynamicCustomerConfig?
    
    var onServiceLogoUpdated: (UIImage?) -> Void = { _ in }
    
    init(environment: Environment, loginMethod: CustomerConfig.PresetMethod) {
        self.environment = environment
        self.loginMethod = loginMethod
    }
}

extension LoginViewModel {
    func prepareDynamicConfiguration(callback: @escaping (DynamicCustomerConfig?) -> Void) {
        applicationConfig = ApplicationConfig(environment: environment)
        applicationConfig?.request { [weak self] in
            self?.loadDynamicConfig(callback: callback)
        }
    }
    
    fileprivate func loadDynamicConfig(callback: @escaping (DynamicCustomerConfig?) -> Void) {
        guard let conf = applicationConfig else {
            callback(nil)
            return
        }
        conf.fetchFile(fileName: "main.json") { [weak self] file in
            if let jsonData = file?.config, let dynamicConfig = DynamicCustomerConfig(json: jsonData) {
                self?.dynamicCustomerConfig = dynamicConfig
//                self?.apply(dynamicConfig: dynamicConfig)
                callback(dynamicConfig)
            }
        }
    }
    
    
//    func apply(dynamicConfig: DynamicCustomerConfig) {
//        if let logoString = dynamicConfig.logoUrl, let logoUrl = URL(string: logoString) {
//            ImagePrefetcher(resources: [logoUrl], options: logoImageOptions(size: CGSize.zero) { [weak self] (image, error, _, _) in
//
//            }.start()
//        }
//    }
    
    func logoImageOptions(size: CGSize) -> KingfisherOptionsInfo {
        return [
            .backgroundDecode,
            .cacheMemoryOnly,
            .processor(CrispResizingImageProcessor(referenceSize: size, mode: .aspectFit))
        ]
    }
}

extension LoginViewModel {
    func anonymous(callback: @escaping (ExposureResponse<SessionToken>) -> Void) {
        Authenticate(environment: environment)
            .anonymous()
            .request()
            .validate()
            .response{ (response: ExposureResponse<SessionToken>) in
                callback(response)
        }
    }
    
    func login(exposureUsername: String, exposurePassword: String, callback: @escaping (ExposureResponse<Credentials>) -> Void) {
        Authenticate(environment: environment)
            .login(username: exposureUsername,
                   password: exposurePassword)
            .request()
            .validate()
            .response { (dataResponse: ExposureResponse<Credentials>) in
                callback(dataResponse)
        }
    }
    
    func twoFactor(exposureUsername: String, exposurePassword: String, mfa: String, callback: @escaping (ExposureResponse<Credentials>) -> Void) {
        Authenticate(environment: environment)
            .twoFactor(username: exposureUsername,
                       password: exposurePassword,
                       twoFactor: mfa)
            .request()
            .validate()
            .response { (dataResponse: ExposureResponse<Credentials>) in
                callback(dataResponse)
        }
    }
}
