import Foundation

final class Prayer : JSONInstantiable {

    var id: NSNumber!
    var prayer: String!
    var createdDate: Date!
    var updatedDate: Date?
    var poster: User?
    
    //MARK: - JSONInstantiable
    required init() {}
    
    var needsReload: Bool {
        return prayer == nil
    }
    
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYY"
        return dateFormatter.string(from: createdDate)
    }
    
    var posterString: String {
        return "Posted By: " + poster!.firstName + " " + poster!.lastName
    }
    
    func read(from jsonObject: MiniJSONObject) throws {
        id = try jsonObject.decode("id")
        prayer = try jsonObject.decode("prayer")
        createdDate = try jsonObject.decode("createdDate")
        updatedDate = try jsonObject.decode("updatedDate")
        poster = try jsonObject.decode("poster")
    }
}
