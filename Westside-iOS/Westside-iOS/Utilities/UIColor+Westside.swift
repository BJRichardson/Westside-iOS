import Foundation
import UIKit

let WESTSIDE_PRIMARY    = 0x2FACDF
let WESTSIDE_ACCENT     = 0x293D93

let DARK_GRAY           = 0x646464
let MID_GRAY            = 0xB4B4B4
let LIGHT_GRAY          = 0xD2D2D2
let LIGHTER_GRAY        = 0xF0F0F0
let OFF_WHITE           = 0xFAFAFA
let ACCENT_GREEN        = 0x69913B
let ACCENT_BLUE         = 0x7D98A9

let CONTROL_COLOR = 0xE7E7E7
// swiftlint:enable variable_name

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
    
    class func primaryColor() -> UIColor {
        return UIColor(hex: WESTSIDE_PRIMARY)
    }
    
    class func accentColor() -> UIColor {
        return UIColor(hex: WESTSIDE_ACCENT)
    }
    
    class func darkGray() -> UIColor {
        return UIColor(hex: DARK_GRAY)
    }
    
    class func midGray() -> UIColor {
        return UIColor(hex: MID_GRAY)
    }
    
    class func lightGray() -> UIColor {
        return UIColor(hex: LIGHT_GRAY)
    }
    
    class func lighterGray() -> UIColor {
        return UIColor(hex: LIGHTER_GRAY)
    }
    
    class func offWhite() -> UIColor {
        return UIColor(hex: OFF_WHITE)
    }
    
    class func accentGreen() -> UIColor {
        return UIColor(hex: ACCENT_GREEN)
    }
    
    class func controlColor() -> UIColor {
        return UIColor(hex: CONTROL_COLOR)
    }
}
