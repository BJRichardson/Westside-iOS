import Foundation
import CoreData
import Forge

@objc(Group)
final class Group : NSManagedObject, ManagedJSONInstantiable {
    @NSManaged var name: String!
    @NSManaged var groupDescription: String?
    @NSManaged var chairPerson: String?
    @NSManaged var email: String?
    @NSManaged var phone: String?
    @NSManaged var imageUrl: String?
    @NSManaged var id: NSNumber!
    
    var needsReload: Bool {
        return name == nil
    }
    
    func read(from jsonObject: JSONObject) throws {
        id = try jsonObject.decode("id")
        name = try jsonObject.decode("title")
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
