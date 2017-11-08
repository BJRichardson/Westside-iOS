import Foundation

class Event: /*NSObject, NSCoding,*/ JSONInstantiable {
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
    
    //MARK: - JSONInstantiable
    required init() {}
    
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
    
//    required init?(coder aDecoder: NSCoder) {
//        id = aDecoder.decodeObject(forKey: Event.idKey) as? NSNumber
//        title = aDecoder.decodeObject(forKey: Event.titleKey) as? String
//        eventDescription = aDecoder.decodeObject(forKey: Event.descriptionKey) as? String
//        startTime = aDecoder.decodeObject(forKey: Event.startTimeKey) as? Date
//        endTime = aDecoder.decodeObject(forKey: Event.endTimeKey) as? Date
//        moreInformation = aDecoder.decodeObject(forKey: Event.moreInfoKey) as? String
//        imageUrl = aDecoder.decodeObject(forKey: Event.imageUrlKey) as? String
//        groups = aDecoder.decodeObject(forKey: Event.groupsKey) as? Array<Group>
//    }
//
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(id, forKey: Event.idKey)
//        aCoder.encode(title, forKey: Event.titleKey)
//        aCoder.encode(eventDescription, forKey: Event.descriptionKey)
//        aCoder.encode(startTime, forKey: Event.startTimeKey)
//        aCoder.encode(endTime, forKey: Event.endTimeKey)
//        aCoder.encode(moreInformation, forKey: Event.moreInfoKey)
//        aCoder.encode(imageUrl, forKey: Event.imageUrlKey)
//        aCoder.encode(groups, forKey: Event.groupsKey)
//    }

    func read(from jsonObject: MiniJSONObject) throws {
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
