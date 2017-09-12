import Foundation
import UIKit

class StringsUtil {
    
    var mDictionary: NSDictionary?

    static let shared = StringsUtil()
    
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
