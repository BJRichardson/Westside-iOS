import UIKit

class Menu: NSObject {
    var destination: UIViewController?
    var title: String!
    var content: ContentDisplayable
    
    init(title: String, destination: UIViewController? = nil, content: ContentDisplayable) {
        self.title = title
        self.destination = destination
        self.content = content
    }
}
