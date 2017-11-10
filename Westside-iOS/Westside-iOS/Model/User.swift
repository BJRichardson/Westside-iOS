import Foundation

class User: JSONInstantiable {

    var id: NSNumber!
    var username: String!
    var firstName: String!
    var lastName: String!
    var email: String!
    var phone: String?
    var address: String?
    var imageUrl: String?
    var roles: String?
    
    //MARK: - JSONInstantiable
    required init() {}
    
    func read(from jsonObject: MiniJSONObject) throws {
        id = try jsonObject.decode("id")
        username = try jsonObject.decode("username")
        firstName = try jsonObject.decode("firstName")
        lastName = try jsonObject.decode("lastName")
        email = try jsonObject.decode("email")
        phone = try jsonObject.decode("phone")
        address = try jsonObject.decode("address")
        imageUrl = try jsonObject.decode("imageUrl")
        roles = try jsonObject.decode("roles")
    }
}
