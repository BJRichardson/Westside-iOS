import Foundation

class User: /*NSObject, NSCoding,*/ JSONInstantiable {

    var id: NSNumber!
    var firstName: String!
    var lastName: String!
    
    //MARK: - JSONInstantiable
    required init() {}
    
    func read(from jsonObject: MiniJSONObject) throws {
        id = try jsonObject.decode("id")
        firstName = try jsonObject.decode("firstName")
        lastName = try jsonObject.decode("lastName")
    }
}
