import Foundation

final class UserEvent : JSONInstantiable {
    
    var id: NSNumber!
    var isAttending: Bool!
    var user: User!
    var event: Event!
    
    //MARK: - JSONInstantiable
    required init() {}
    
    func read(from jsonObject: MiniJSONObject) throws {
        id = try jsonObject.decode("id")
        isAttending = try jsonObject.decode("isAttending")
        user = try jsonObject.decode("user")
        event = try jsonObject.decode("event")
    }
}
