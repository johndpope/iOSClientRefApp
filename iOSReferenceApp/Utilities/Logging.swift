class Logging {
//    Swift Compiler - Custom Flags
//    Debug: -D DEBUG
    
//    Global: let LOGGING = Logging.sharedInstance
    
    class var sharedInstance : Logging {
        struct Static {
            static let instance : Logging = Logging()
        }
        return Static.instance
    }
    
    func d(logs: String){
        #if DEBUG
            print(logs)
        #endif
    }
    
    func e(logs: String){
        #if DEBUG
            print(logs)
        #else
            //Report to server
        #endif
    }
}
