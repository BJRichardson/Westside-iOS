import Foundation

class Announcement: /*NSObject, NSCoding,*/ JSONInstantiable {
    private static let idKey = "id"
    private static let announcementKey = "announcement"
    private static let createdKey = "createdDate"
    private static let updatedKey = "updatedDate"
    private static let groupIdKey = "groupId"
    private static let posterKey = "poster"
    private static let imageUrlKey = "imageUrl"
    
    var id: NSNumber!
    var announcement: String!
    var createdDate: Date!
    var updatedDate: Date?
    var groupId: NSNumber!
    var imageUrl: String?
    var poster: User?
    
    //MARK: - JSONInstantiable
    required init() {}
    
    var needsReload: Bool {
        return announcement == nil
    }
    
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYY"
        return dateFormatter.string(from: createdDate)
    }
    
    var posterString: String {
        return "Posted By: " + poster!.firstName + " " + poster!.lastName
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
        announcement = try jsonObject.decode("announcement")
        createdDate = try jsonObject.decode("createdDate")
        updatedDate = try jsonObject.decode("updatedDate")
        groupId = try jsonObject.decode("groupId")
        imageUrl = try jsonObject.decode("imageUrl")
        poster = try jsonObject.decode("poster")
    }
}
