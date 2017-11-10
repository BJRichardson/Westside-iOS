import Foundation

enum ContentActionable {
    case login
    case logout
}

enum ContentDisplayable {
    case view
    case action(ContentActionable)
}
