class Logging {
//    Swift Compiler - Custom Flags
//    Debug: -D DEBUG
    
    static let shared = Logging()
    
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
