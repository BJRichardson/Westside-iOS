import Foundation
import Forge

class EventFix: NSObject, NSCoding, JSONInstantiable {
    private static let idKey = "id"
    private static let titleKey = "title"
    private static let descriptionKey = "description"
    private static let startTimeKey = "startTime"
    private static let endTimeKey = "endTime"
    private static let moreInfoKey = "moreInformation"
    private static let imageUrlKey = "imageUrl"
    private static let groupsKey = "groups"
    
    var id: NSNumber!
    var title: String!
    var eventDescription: String?
    var startTime: Date!
    var endTime: Date?
    var moreInformation: String?
    var imageUrl: String?
    var groups: Array<Group>?
    
    required init(with jsonObject: JSONObject) throws {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: EventFix.idKey) as? NSNumber
        title = aDecoder.decodeObject(forKey: EventFix.titleKey) as? String
        eventDescription = aDecoder.decodeObject(forKey: EventFix.descriptionKey) as? String
        startTime = aDecoder.decodeObject(forKey: EventFix.startTimeKey) as? Date
        endTime = aDecoder.decodeObject(forKey: EventFix.endTimeKey) as? Date
        moreInformation = aDecoder.decodeObject(forKey: EventFix.moreInfoKey) as? String
        imageUrl = aDecoder.decodeObject(forKey: EventFix.imageUrlKey) as? String
        groups = aDecoder.decodeObject(forKey: EventFix.groupsKey) as? Array<Group>
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: EventFix.idKey)
        aCoder.encode(title, forKey: EventFix.titleKey)
        aCoder.encode(eventDescription, forKey: EventFix.descriptionKey)
        aCoder.encode(startTime, forKey: EventFix.startTimeKey)
        aCoder.encode(endTime, forKey: EventFix.endTimeKey)
        aCoder.encode(moreInformation, forKey: EventFix.moreInfoKey)
        aCoder.encode(imageUrl, forKey: EventFix.imageUrlKey)
        aCoder.encode(groups, forKey: EventFix.groupsKey)
    }

    func read(from jsonObject: JSONObject) throws {
        id = try jsonObject.decode("id")
        title = try jsonObject.decode("title")
        eventDescription = try jsonObject.decode("description")
        startTime = try jsonObject.decode("startTime")
        endTime = try jsonObject.decode("endTime")
        moreInformation = try jsonObject.decode("moreInformation")
        imageUrl = try jsonObject.decode("imageUrl")
        
        groups = try jsonObject.decode("groups")
    }
}
