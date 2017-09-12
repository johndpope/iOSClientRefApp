import Foundation
import UIKit

class ColorsUtil {
    var mDictionary: NSDictionary?
    
    static let shared = ColorsUtil()
    
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
