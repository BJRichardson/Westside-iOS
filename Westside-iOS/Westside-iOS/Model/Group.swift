import Foundation

final class Group : JSONInstantiable {
    var name: String!
    var groupDescription: String?
    var chairPerson: String?
    var email: String?
    var phone: String?
    var imageUrl: String?
    var id: NSNumber!
    
    //MARK: - JSONInstantiable
    required init() {}
    
    var needsReload: Bool {
        return name == nil
    }
    
    func read(from jsonObject: MiniJSONObject) throws {
        id = try jsonObject.decode("id")
        name = try jsonObject.decode("name")
        groupDescription = try jsonObject.decode("description")
        chairPerson = try jsonObject.decode("chairperson")
        email = try jsonObject.decode("email")
        phone = try jsonObject.decode("phone")
        imageUrl = try jsonObject.decode("imageUrl")
    }
    
    static func matchKeys() -> (managedKey: String, jsonKey: String)? {
        return ("id", "id")
    }
}
