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
        
        let crmToken = TinyDB.string(for: UserInfo.Lets.KEY_CRM_TOKEN)
        let accountId = TinyDB.string(for: UserInfo.Lets.KEY_ACCOUNT_ID)
        
        var expiration: Date? = nil
        if let expirationDateTime = TinyDB.string(for: UserInfo.Lets.KEY_EXPIRATION_DATE_TIME) {
            expiration = Date
                .utcFormatter()
                .date(from: expirationDateTime)
        }
        let accountStatus = TinyDB.string(for: UserInfo.Lets.KEY_ACCOUNT_STATUS)
        
        return Credentials(sessionToken: session,
                           crmToken: crmToken,
                           accountId: accountId,
                           expiration: expiration,
                           accountStatus: accountStatus)
    }
    
    static var sessionToken: SessionToken? {
        return SessionToken(value: TinyDB.string(for: UserInfo.Lets.KEY_SESSION_TOKEN))
    }
    
    static var environment: Environment? {
        guard let customer = TinyDB.string(for: UserInfo.Lets.KEY_CUSTOMER),
            let businessUnit = TinyDB.string(for: UserInfo.Lets.KEY_CUSTOMER_BUSINESS_UNIT),
            let environmentUrl = TinyDB.string(for: UserInfo.Lets.KEY_ENVIRONMENT_URL) else { return nil }
        
        return Environment(baseUrl: environmentUrl,
                           customer: customer,
                           businessUnit: businessUnit)
    }
    
    static var environmentUsesMfa: Bool {
        return TinyDB.bool(for: UserInfo.Lets.KEY_ENVIRONMENT_LOGIN_METHOD) ?? false
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
        static let KEY_ENVIRONMENT_LOGIN_METHOD = "kEnvironmentLoginMethod"
    }
    
}

// MARK: General functions
extension UserInfo {
    
    static func isValidSession() -> Bool{
        return sessionToken != nil
    }
    
    static func clear() {
        clearSession()
        
        // Environment
        TinyDB.remove(key: UserInfo.Lets.KEY_ENVIRONMENT_URL)
        TinyDB.remove(key: UserInfo.Lets.KEY_CUSTOMER)
        TinyDB.remove(key: UserInfo.Lets.KEY_CUSTOMER_BUSINESS_UNIT)
        TinyDB.remove(key: UserInfo.Lets.KEY_ENVIRONMENT_LOGIN_METHOD)
    }
}

// MARK: User info updating
extension UserInfo {
    
    static func update(credentials: Credentials) {
        update(sessionToken: credentials.sessionToken)
        
        if let crmToken = credentials.crmToken {
            TinyDB.save(string: crmToken, for: UserInfo.Lets.KEY_CRM_TOKEN)
        }
        if let accountId = credentials.accountId {
            TinyDB.save(string: accountId, for: UserInfo.Lets.KEY_ACCOUNT_ID)
        }
        if let expirationDate = credentials.expiration {
            let expiration = Date.utcFormatter().string(from: expirationDate)
            TinyDB.save(string: expiration, for: UserInfo.Lets.KEY_EXPIRATION_DATE_TIME)
        }
        if let accountStatus = credentials.accountStatus {
            TinyDB.save(string: accountStatus, for: UserInfo.Lets.KEY_ACCOUNT_STATUS)
        }
    }
    
    static func update(sessionToken: SessionToken) {
        TinyDB.save(string: sessionToken.value, for: UserInfo.Lets.KEY_SESSION_TOKEN)
    }
    
    static func clearSession() {
        // Credentials
        TinyDB.remove(key: UserInfo.Lets.KEY_SESSION_TOKEN)
        TinyDB.remove(key: UserInfo.Lets.KEY_CRM_TOKEN)
        TinyDB.remove(key: UserInfo.Lets.KEY_ACCOUNT_ID)
        TinyDB.remove(key: UserInfo.Lets.KEY_EXPIRATION_DATE_TIME)
        TinyDB.remove(key: UserInfo.Lets.KEY_ACCOUNT_STATUS)
    }
    
    static func update(environment: Environment) {
        // Environment
        TinyDB.save(string: environment.baseUrl, for: UserInfo.Lets.KEY_ENVIRONMENT_URL)
        
        // Customer
        TinyDB.save(string: environment.customer, for: UserInfo.Lets.KEY_CUSTOMER)
        TinyDB.save(string: environment.businessUnit, for: UserInfo.Lets.KEY_CUSTOMER_BUSINESS_UNIT)
    }
    
    static func environment(usesMfa: Bool) {
        TinyDB.save(bool: usesMfa, for: UserInfo.Lets.KEY_ENVIRONMENT_LOGIN_METHOD)
    }
}
