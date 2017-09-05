import Foundation
import UIKit

class StringsUtil {
    //    Global: let STRINGS_UTIL = StringsUtil.sharedInstance
    
    var mDictionary: NSDictionary?
    
    class var sharedInstance : StringsUtil {
        struct Static {
            static let instance : StringsUtil = StringsUtil()
        }
        return Static.instance
    }
    
    init(){
        initDictionary()
    }
    
    func initDictionary(){
        let path = Bundle.main.path(forResource: "strings.plist", ofType: nil)
        mDictionary = NSDictionary(contentsOfFile: path!)
    }
    
    func getString(key: String) -> String{
        if let value = mDictionary!.object(forKey: key) as? String {
            return value
        } else{
            // if nil, return empty
            return ""
        }
    }
}
