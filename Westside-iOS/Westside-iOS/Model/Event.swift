import Foundation

class Event: JSONInstantiable {
    
    var id: NSNumber!
    var title: String!
    var eventDescription: String?
    var startTime: Date!
    var endTime: Date?
    var moreInformation: String?
    var imageUrl: String?
    var groups: Array<Group>?
    var users: Array<User>?
    
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
    
    var timeString: String {
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: startTime)
    }

    func read(from jsonObject: MiniJSONObject) throws {
        id = try jsonObject.decode("id")
        title = try jsonObject.decode("title")
        eventDescription = try jsonObject.decode("description")
        startTime = try jsonObject.decode("startTime")
        endTime = try jsonObject.decode("endTime")
        moreInformation = try jsonObject.decode("moreInformation")
        imageUrl = try jsonObject.decode("imageUrl")
        groups = try jsonObject.decode("groups")
        users = try jsonObject.decode("users") 
    }
}
