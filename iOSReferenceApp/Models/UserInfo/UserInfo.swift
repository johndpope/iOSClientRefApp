//
//  UserInfo.swift
//  iOSReferenceApp
//
//  Created by Hui Wang on 2017-05-15.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

enum UserInfo {
    static var credentials: Credentials? {
        guard let session = sessionToken else { return nil }
        
        let crmToken = TINY_DB.getString(UserInfo.Lets.KEY_CRM_TOKEN)
        let accountId = TINY_DB.getString(UserInfo.Lets.KEY_ACCOUNT_ID)
        
        var expiration: Date? = nil
        if let expirationDateTime = TINY_DB.getString(UserInfo.Lets.KEY_EXPIRATION_DATE_TIME) {
            expiration = Date
                .utcFormatter()
                .date(from: expirationDateTime)
        }
        let accountStatus = TINY_DB.getString(UserInfo.Lets.KEY_ACCOUNT_STATUS)
        
        return Credentials(sessionToken: session,
                           crmToken: crmToken,
                           accountId: accountId,
                           expiration: expiration,
                           accountStatus: accountStatus)
    }
    
    static var sessionToken: SessionToken? {
        return SessionToken(value: TINY_DB.getString(UserInfo.Lets.KEY_SESSION_TOKEN))
    }
    
    static var environment: Environment? {
        guard let customer = TINY_DB.getString(UserInfo.Lets.KEY_CUSTOMER),
            let businessUnit = TINY_DB.getString(UserInfo.Lets.KEY_CUSTOMER_BUSINESS_UNIT),
            let environmentUrl = TINY_DB.getString(UserInfo.Lets.KEY_ENVIRONMENT_URL) else { return nil }
        
        return Environment(baseUrl: environmentUrl,
                           customer: customer,
                           businessUnit: businessUnit)
    }
    
    struct Lets {
        // Credentials
        static let KEY_SESSION_TOKEN = "kSessionToken"
        static let KEY_CRM_TOKEN = "kCrmToken"
        static let KEY_ACCOUNT_ID = "kAccountId"
        static let KEY_EXPIRATION_DATE_TIME = "kExpirationDateTime"
        static let KEY_ACCOUNT_STATUS = "kAccountStatus"
        
        
        // Environment
        static let KEY_ENVIRONMENT_URL = "kEnvironmentUrl"
        static let KEY_CUSTOMER = "kCustomer"
        static let KEY_CUSTOMER_BUSINESS_UNIT = "kCustomerBusinessUnit"
    }
    
}

// MARK: General functions
extension UserInfo {
    
    static func isValidSession() -> Bool{
        return sessionToken != nil
    }
    
    static func clear() {
        // Credentials
        TINY_DB.removeData(byKey: UserInfo.Lets.KEY_SESSION_TOKEN)
        TINY_DB.removeData(byKey: UserInfo.Lets.KEY_CRM_TOKEN)
        TINY_DB.removeData(byKey: UserInfo.Lets.KEY_ACCOUNT_ID)
        TINY_DB.removeData(byKey: UserInfo.Lets.KEY_EXPIRATION_DATE_TIME)
        TINY_DB.removeData(byKey: UserInfo.Lets.KEY_ACCOUNT_STATUS)
        
        // Environment
        TINY_DB.removeData(byKey: UserInfo.Lets.KEY_ENVIRONMENT_URL)
        TINY_DB.removeData(byKey: UserInfo.Lets.KEY_CUSTOMER)
        TINY_DB.removeData(byKey: UserInfo.Lets.KEY_CUSTOMER_BUSINESS_UNIT)
    }
}

// MARK: User info updating
extension UserInfo {
    
    static func update(credentials: Credentials) {
        update(sessionToken: credentials.sessionToken)
        
        if let crmToken = credentials.crmToken {
            TINY_DB.save(crmToken, withKey: UserInfo.Lets.KEY_CRM_TOKEN)
        }
        if let accountId = credentials.accountId {
            TINY_DB.save(accountId, withKey: UserInfo.Lets.KEY_ACCOUNT_ID)
        }
        if let expirationDate = credentials.expiration {
            let expiration = Date.utcFormatter().string(from: expirationDate)
            TINY_DB.save(expiration, withKey: UserInfo.Lets.KEY_EXPIRATION_DATE_TIME)
        }
        if let accountStatus = credentials.accountStatus {
            TINY_DB.save(accountStatus, withKey: UserInfo.Lets.KEY_ACCOUNT_STATUS)
        }
    }
    
    static func update(sessionToken: SessionToken) {
        TINY_DB.save(sessionToken.value, withKey: UserInfo.Lets.KEY_SESSION_TOKEN)
    }
    
    static func update(environment: Environment) {
        // Environment
        TINY_DB.save(environment.baseUrl, withKey: UserInfo.Lets.KEY_ENVIRONMENT_URL)
        
        // Customer
        TINY_DB.save(environment.customer, withKey: UserInfo.Lets.KEY_CUSTOMER)
        TINY_DB.save(environment.businessUnit, withKey: UserInfo.Lets.KEY_CUSTOMER_BUSINESS_UNIT)
    }
    
}
