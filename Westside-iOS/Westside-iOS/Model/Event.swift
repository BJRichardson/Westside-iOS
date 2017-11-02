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
    
    var needsReload: Bool {
        return title == nil || startTime == nil
    }
    
    var startString: String {
        return Event.formatter.string(from: startTime)
    }
    
    var endString: String {
        guard let endTime = endTime else {
            return "???"
        }
        
        return Event.formatter.string(from: endTime)
    }
    
    static let formatter = { () -> DateFormatter in
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter
    }()
    
    func read(from jsonObject: JSONObject) throws {
        id = try jsonObject.decode("id")
        title = try jsonObject.decode("title")
        eventDescription = try jsonObject.decode("description")
        startTime = try jsonObject.decode("startTime")
        endTime = try jsonObject.decode("endTime")
        moreInformation = try jsonObject.decode("moreInformation")
        imageUrl = try jsonObject.decode("imageUrl")
    }
    
    static func matchKeys() -> (managedKey: String, jsonKey: String)? {
        return ("id", "id")
    }
}
