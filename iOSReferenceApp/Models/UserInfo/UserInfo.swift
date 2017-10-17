//
//  UserInfo.swift
//  iOSReferenceApp
//
//  Created by Hui Wang on 2017-05-15.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure
import Utilities

enum UserInfo {
    static var credentials: Credentials? {
        guard let session = sessionToken else { return nil }
        
        let crmToken = TinyDB.getString(UserInfo.Lets.KEY_CRM_TOKEN)
        let accountId = TinyDB.getString(UserInfo.Lets.KEY_ACCOUNT_ID)
        
        var expiration: Date? = nil
        if let expirationDateTime = TinyDB.getString(UserInfo.Lets.KEY_EXPIRATION_DATE_TIME) {
            expiration = Date
                .utcFormatter()
                .date(from: expirationDateTime)
        }
        let accountStatus = TinyDB.getString(UserInfo.Lets.KEY_ACCOUNT_STATUS)
        
        return Credentials(sessionToken: session,
                           crmToken: crmToken,
                           accountId: accountId,
                           expiration: expiration,
                           accountStatus: accountStatus)
    }
    
    static var sessionToken: SessionToken? {
        return SessionToken(value: TinyDB.getString(UserInfo.Lets.KEY_SESSION_TOKEN))
    }
    
    static var environment: Environment? {
        guard let customer = TinyDB.getString(UserInfo.Lets.KEY_CUSTOMER),
            let businessUnit = TinyDB.getString(UserInfo.Lets.KEY_CUSTOMER_BUSINESS_UNIT),
            let environmentUrl = TinyDB.getString(UserInfo.Lets.KEY_ENVIRONMENT_URL) else { return nil }
        
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
        TinyDB.removeData(byKey: UserInfo.Lets.KEY_SESSION_TOKEN)
        TinyDB.removeData(byKey: UserInfo.Lets.KEY_CRM_TOKEN)
        TinyDB.removeData(byKey: UserInfo.Lets.KEY_ACCOUNT_ID)
        TinyDB.removeData(byKey: UserInfo.Lets.KEY_EXPIRATION_DATE_TIME)
        TinyDB.removeData(byKey: UserInfo.Lets.KEY_ACCOUNT_STATUS)
        
        // Environment
        TinyDB.removeData(byKey: UserInfo.Lets.KEY_ENVIRONMENT_URL)
        TinyDB.removeData(byKey: UserInfo.Lets.KEY_CUSTOMER)
        TinyDB.removeData(byKey: UserInfo.Lets.KEY_CUSTOMER_BUSINESS_UNIT)
    }
}

// MARK: User info updating
extension UserInfo {
    
    static func update(credentials: Credentials) {
        update(sessionToken: credentials.sessionToken)
        
        if let crmToken = credentials.crmToken {
            TinyDB.save(crmToken, withKey: UserInfo.Lets.KEY_CRM_TOKEN)
        }
        if let accountId = credentials.accountId {
            TinyDB.save(accountId, withKey: UserInfo.Lets.KEY_ACCOUNT_ID)
        }
        if let expirationDate = credentials.expiration {
            let expiration = Date.utcFormatter().string(from: expirationDate)
            TinyDB.save(expiration, withKey: UserInfo.Lets.KEY_EXPIRATION_DATE_TIME)
        }
        if let accountStatus = credentials.accountStatus {
            TinyDB.save(accountStatus, withKey: UserInfo.Lets.KEY_ACCOUNT_STATUS)
        }
    }
    
    static func update(sessionToken: SessionToken) {
        TinyDB.save(sessionToken.value, withKey: UserInfo.Lets.KEY_SESSION_TOKEN)
    }
    
    static func update(environment: Environment) {
        // Environment
        TinyDB.save(environment.baseUrl, withKey: UserInfo.Lets.KEY_ENVIRONMENT_URL)
        
        // Customer
        TinyDB.save(environment.customer, withKey: UserInfo.Lets.KEY_CUSTOMER)
        TinyDB.save(environment.businessUnit, withKey: UserInfo.Lets.KEY_CUSTOMER_BUSINESS_UNIT)
    }
    
}
