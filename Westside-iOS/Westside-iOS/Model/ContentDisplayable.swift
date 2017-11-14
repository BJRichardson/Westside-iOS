import Foundation

enum ContentActionable {
    case register
    case login
    case logout
}

enum ContentDisplayable {
    case view
    case action(ContentActionable)
}
