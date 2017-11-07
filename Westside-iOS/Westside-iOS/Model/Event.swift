import Foundation
import CoreData
import Forge

@objc(Event)
final class Event : NSManagedObject, ManagedJSONInstantiable {
    @NSManaged var title: String!
    @NSManaged var eventDescription: String?
    @NSManaged var startTime: Date!
    @NSManaged var endTime: Date?
    @NSManaged var moreInformation: String?
    @NSManaged var imageUrl: String?
    @NSManaged var groups: Array<Group>?
    @NSManaged var id: NSNumber!
    
    var dateFormatter = DateFormatter()
    
    var needsReload: Bool {
        return title == nil || startTime == nil
    }
    
    var monthString: String {
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: startTime)
    }
    
    var dateString: String {
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: startTime)
    }
    
    func read(from jsonObject: JSONObject) throws {
        id = try jsonObject.decode("id")
        title = try jsonObject.decode("title")
        eventDescription = try jsonObject.decode("description")
        startTime = try jsonObject.decode("startTime")
        endTime = try jsonObject.decode("endTime")
        moreInformation = try jsonObject.decode("moreInformation")
        imageUrl = try jsonObject.decode("imageUrl")
        //groups = try jsonObject.decode("groups")
    }
    
    static func matchKeys() -> (managedKey: String, jsonKey: String)? {
        return ("id", "id")
    }
}
