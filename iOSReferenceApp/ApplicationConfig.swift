//
//  ApplicationConfig.swift
//  iOSReferenceApp
//
//  Created by Viktor Gardart on 2017-10-04.
//  Copyright © 2017 emp. All rights reserved.
//

import Exposure

class ApplicationConfig {

  let environment: Environment
  var customerConfig: Exposure.CustomerConfig?

  init(environment: Environment) {
    self.environment = environment
  }

  func request(completion: @escaping () -> Void) {
    CustomerConfigRequest(environment: environment)
      .request()
      .validate()
      .response { [weak self] response in
        let t = response.value
        self?.customerConfig = response.value
        completion()
    }
  }

  func fetchFile(fileName name: String,
                 completion: @escaping (_ file: Exposure.CustomerConfig.File?) -> Void) {
    CustomerConfigFileRequest(fileName: name,
                              environment: environment)
      .request()
      .validate()
      .response { response in
        completion(response.value)
    }
  }

}
