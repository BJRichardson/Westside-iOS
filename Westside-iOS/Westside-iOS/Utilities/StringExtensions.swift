import Foundation

extension String {
    func toJSON() -> AnyObject? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
    }
}

extension String {
    var numericText: String {
        return components(separatedBy: .nonNumeric).joined()
    }
    
    func substring(to index: Int) -> String {
        return substring(to: self.index(startIndex, offsetBy: index))
    }
    
    mutating func insert(_ character: Character, at index: Int) {
        insert(character, at: self.index(startIndex, offsetBy: index))
    }
    
    mutating func remove(at index: Int) {
        remove(at: self.index(startIndex, offsetBy: index))
    }
}

extension CharacterSet {
    static var nonNumeric = NSCharacterSet.decimalDigits.inverted
}

