import Foundation
import CoreData
import Forge

class Store {
    
    static let sharedStore = Store()
    static let resourceEndpoint = "https://westsidecme.herokuapp.com/health"
    static let serverOverrideKey = "serverOverrideURL"
    static let tokenKey = "token"
    
    var managedObjectContext: NSManagedObjectContext
    
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
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = Bundle.main.url(forResource: "westside", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        let storeURL = docURL.appendingPathComponent("DataModel.sqlite")
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            try! psc.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
            fatalError("Error migrating store: \(error)")
        }
        
        TransportGateway.defaultGateway.baseURL = UserDefaults.standard.url(forKey: Store.serverOverrideKey) ?? environment.url
    }
    
    func fetchEvents(completion: @escaping (URLResult<Array<Event>>) -> Void) {
        let request: EntityListRequest<Event> = TransportGateway.defaultGateway.makeRequest(identifiers: ["events"])
        request.transformer.context = managedObjectContext
        request.basicAuthorizationUsername = environment.clientId
        request.basicAuthorizationPassword = environment.clientSecret
        request.completion = { result in
            if case .value = result {
                self.saveContext()
            }
            completion(result)
        }
        TransportGateway.defaultGateway.executeWithoutAuthentication(request)
    }
    
    func saveContext() {
        do {
            try managedObjectContext.save()
        } catch let error {
            print("Exception saving: \(error)")
        }
    }
}
