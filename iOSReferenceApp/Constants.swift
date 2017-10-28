class Constants {
    
    // MARK: - Storyboard
    struct Storyboard {
        static let rootNavId = "ROOT_NAV_ID"
        static let loginId = "LOGIN_VC_ID"
        static let homeId = "HOME_TBC_ID"
        static let masterView = "masterView"
        
        static let homeSegue = "HOME_TBC_SEGUE"
    }
    
    // MARK: - Colors
    struct Colors {
        struct Ericsson {
            static let blue = "ericsson_blue"
            static let black = "ericsson_black"
        }
    }
    
    // MARK: - Strings
    struct Strings {
        static let appName = "app_name"
        static let environment = "environment"
        static let customer = "customer"
        static let error = "error"

        struct Error {
            static let invalidEnvironment = "error_invalid_environment"
            static let invalidCustomer = "error_invalid_customer"
            static let invalidUsername = "error_invalid_username"
            static let invalidPassword = "error_invalid_password"
        }
    }

}
