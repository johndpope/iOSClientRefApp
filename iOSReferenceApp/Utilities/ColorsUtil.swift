import Foundation
import UIKit

class ColorsUtil {
    //    Global: let COLORS_UTIL = ColorsUtil.sharedInstance
    
    var mDictionary: NSDictionary?
    
    class var sharedInstance : ColorsUtil {
        struct Static {
            static let instance : ColorsUtil = ColorsUtil()
        }
        return Static.instance
    }
    
    init(){
        let path = Bundle.main.path(forResource: "colors.plist", ofType: nil)
        mDictionary = NSDictionary(contentsOfFile: path!) // NOTE: Using implicitly unwrapped optionals here is dangerous. If Bundle.main.path for colors.plist fails, this will crash.
    }
    
    func getColor(key: String) -> UIColor{
        if let value = mDictionary!.object(forKey: key) as? String {
            return UIColor(value)
        } else{
            // if nil, return purple color
            return UIColor("ff00ff")
        }
    }
}
