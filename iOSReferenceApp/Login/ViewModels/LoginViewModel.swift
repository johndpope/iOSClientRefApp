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
    
    var onServiceLogoUpdated: (UIImage?) -> Void = { _ in }
    
    init(environment: Environment, loginMethod: CustomerConfig.PresetMethod) {
        self.environment = environment
        self.loginMethod = loginMethod
    }
}

extension LoginViewModel {
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
            .response{
                callback($0)
        }
    }
    
//    func login(exposureUsername: String, exposurePassword: String, callback: @escaping (ExposureResponse<Credentials>) -> Void) {
//        Authenticate(environment: environment)
//            .login(username: exposureUsername,
//                   password: exposurePassword)
//            .request()
//            .validate()
//            .response { (dataResponse: ExposureResponse<Credentials>) in
//                callback(dataResponse)
//        }
//    }
    
    func login(exposureUsername: String, exposurePassword: String, mfa: String? = nil, callback: @escaping (ExposureResponse<Credentials>) -> Void) {
        Authenticate(environment: environment)
            .login(username: exposureUsername,
                   password: exposurePassword,
                   twoFactor: mfa)
            .request()
            .validate()
            .response {
                callback($0)
        }
    }
}
