import Foundation

final class UserGroup : JSONInstantiable {
    
    var id: NSNumber!
    var user: User!
    var group: Group!
    
    //MARK: - JSONInstantiable
    required init() {}
    
    func read(from jsonObject: MiniJSONObject) throws {
        id = try jsonObject.decode("id")
        user = try jsonObject.decode("user")
        group = try jsonObject.decode("group")
    }
}
