import Foundation
import CoreData
//import Forge

class Store {
    
    static let sharedStore = Store()
    static let resourceEndpoint = "https://westsidecme.herokuapp.com/health"
    static let serverOverrideKey = "serverOverrideURL"
    static let tokenKey = "token"
    
    var user: User?
    
    var isUserLoggedIn: Bool {
        return user != nil
    }
    
    var unauthedMenus: Array<Menu> {
        var menuItems: Array<Menu> = []
        menuItems.append(Menu(title: "Login", destination: nil, content: .action(.login)))
        menuItems.append(Menu(title: "Create Account", destination: nil, content: .action(.register)))
        return menuItems
    }
    
    var authedMenus: Array<Menu> {
        var menuItems: Array<Menu> = []
        menuItems.append(Menu(title: "Logout", destination: nil, content: .action(.logout)))
        return menuItems
    }
    
    //var managedObjectContext: NSManagedObjectContext
    
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
    
    var environment: Environment = .staging {
        didSet {
            TransportGateway.defaultGateway.baseURL = environment.url
            UserDefaults.standard.set(environment.url, forKey: Store.serverOverrideKey)
        }
    }
    
    init() {
//        // This resource is the same name as your xcdatamodeld contained in your project.
//        guard let modelURL = Bundle.main.url(forResource: "westside", withExtension:"momd") else {
//            fatalError("Error loading model from bundle")
//        }
//
//        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
//        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
//            fatalError("Error initializing mom from: \(modelURL)")
//        }
//
//        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
//        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        managedObjectContext.persistentStoreCoordinator = psc
//        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let docURL = urls[urls.endIndex-1]
//        /* The directory the application uses to store the Core Data store file.
//         This code uses a file named "DataModel.sqlite" in the application's documents directory.
//         */
//        let storeURL = docURL.appendingPathComponent("DataModel.sqlite")
//        do {
//            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
//        } catch {
//            try! psc.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
//            fatalError("Error migrating store: \(error)")
//        }
//
        TransportGateway.defaultGateway.baseURL = UserDefaults.standard.url(forKey: Store.serverOverrideKey) ?? environment.url
    }
    
    func fetchEvents(completion: @escaping (URLResult<Array<Event>>) -> Void) {
        let request: ResourceListRequest<Event> = TransportGateway.defaultGateway.makeRequest(identifiers: ["events"])
        request.basicAuthorizationUsername = environment.clientId
        request.basicAuthorizationPassword = environment.clientSecret
        request.completion = { result in
            if case .value = result {
                //self.saveContext()
            }
            completion(result)
        }
        TransportGateway.defaultGateway.executeWithoutAuthentication(request)
    }
    
    func fetchAnnouncements(completion: @escaping (URLResult<Array<Announcement>>) -> Void) {
        let request: ResourceListRequest<Announcement> = TransportGateway.defaultGateway.makeRequest(identifiers: ["announcements"])
        request.basicAuthorizationUsername = environment.clientId
        request.basicAuthorizationPassword = environment.clientSecret
        request.completion = { result in
            if case .value = result {
                //self.saveContext()
            }
            completion(result)
        }
        TransportGateway.defaultGateway.executeWithoutAuthentication(request)
    }
    
    func fetchPrayers(completion: @escaping (URLResult<Array<Prayer>>) -> Void) {
        let request: ResourceListRequest<Prayer> = TransportGateway.defaultGateway.makeRequest(identifiers: ["prayers"])
        request.basicAuthorizationUsername = environment.clientId
        request.basicAuthorizationPassword = environment.clientSecret
        request.completion = { result in
            if case .value = result {
                //self.saveContext()
            }
            completion(result)
        }
        TransportGateway.defaultGateway.executeWithoutAuthentication(request)
    }
    
    func loginWith(username: String, password: String, completion: ((Error?) -> Void)?) {
        let request: ResourceRequest<OAuthToken> = TransportGateway.defaultGateway.makeRequest(identifiers: ["auth", "token"])
        request.completion = tokenCompletion(completion: completion)
        request.method = .post
        request.basicAuthorizationUsername = environment.clientId
        request.basicAuthorizationPassword = environment.clientSecret
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "grant_type",value: "password")
        ]
        request.httpBody = components.query?.data(using: .utf8)
        TransportGateway.defaultGateway.executeWithoutAuthentication(request)
    }
    
    func logout() {
        user = nil
        UserDefaults.standard.removeObject(forKey: Store.tokenKey)
        TransportGateway.defaultGateway.token = nil
        UserDefaults.standard.removeObject(forKey: Store.tokenKey)
    }
    
    func registerWith(username: String, password: String, phone: String, firstName: String, lastName: String, completion: ((Error?) -> Void)?) {
        let request: ResourceRequest<OAuthToken> = TransportGateway.defaultGateway.makeRequest(identifiers: ["register"])
        request.completion = tokenCompletion(completion: completion)
        request.method = .post
        request.basicAuthorizationUsername = environment.clientId
        request.basicAuthorizationPassword = environment.clientSecret
        request.bodyValues = [
            "username" : username,
            "password" : password,
            "phone" : phone,
            "firstName" : firstName,
            "lastName" : lastName,
        ]
        TransportGateway.defaultGateway.executeWithoutAuthentication(request)
    }
   
    func joinEvent(event: Event, completion: @escaping (URLResult<UserEvent>) -> Void) {
        let request: ResourceRequest<UserEvent> = TransportGateway.defaultGateway.makeRequest(identifiers: ["schedule", event.id.intValue])
        request.method = .post
        request.completion = { result in
            completion(result)
        }
        TransportGateway.defaultGateway.enqueueForAuthentication(request)
    }
    
    func leaveEvent(event: Event) {
        let request: JSONRequest = TransportGateway.defaultGateway.makeRequest(identifiers: ["schedule", event.id.intValue])
        request.method = .delete
        TransportGateway.defaultGateway.enqueueForAuthentication(request)
    }
    
    func tokenCompletion(completion: ((Error?) -> Void)?) -> (URLResult<OAuthToken>) -> Void {
        return { tokenResult in
            switch tokenResult {
            case .value(let token, _):
                TransportGateway.defaultGateway.token = token
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: token), forKey: Store.tokenKey)
                self.getIdentity { userResult in
                    switch userResult {
                    case .value:
                        completion?(nil)
                    case .error(let error):
                        completion?(error)
                    }
                }
            case .error(let error):
                completion?(error)
            }
        }
    }
    
    func getIdentity(completion: ((URLResult<User>) -> Void)? = nil) {
        let request: ResourceRequest<User> = TransportGateway.defaultGateway.makeRequest(identifiers: ["me"])
        request.completion = { result in
            if case let .value(u,_) = result {
                self.user = u
                //self.saveContext()
            }
            completion?(result)
        }
        //request.transformer.context = managedObjectContext
        TransportGateway.defaultGateway.enqueueForAuthentication(request)
    }
    
//    func saveContext() {
//        do {
//            try managedObjectContext.save()
//        } catch let error {
//            print("Exception saving: \(error)")
//        }
//    }
}
