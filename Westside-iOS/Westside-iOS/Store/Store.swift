import Foundation
import CoreData

class Store: NSObject {
    
    static let sharedInstance = Store()
    static let resourceEndpoint = "https://westsidecme.herokuapp.com/"
    
    static let serverOverrideKey = "serverOverrideURL"
    static let tokenKey = "token"
    
    enum Environment: String {
        case staging
        case production
        
        var url: URL {
            switch self {
            case .production:
                return URL(string: "https://westsidecme.herokuapp.com/")!
            case .staging:
                return URL(string: "https://westsidecme.herokuapp.com/")!
            }
        }
        
        var clientId: String {
            return "com.westside.backend"
        }
        var clientSecret: String {
            return "fellowship1953"
        }
    }
}
