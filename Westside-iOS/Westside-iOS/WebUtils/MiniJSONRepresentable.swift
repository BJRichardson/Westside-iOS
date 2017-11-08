import Foundation
import CoreData

/**
 Protocol for indicating that a model object can be converted to and from JSON
 */
public protocol JSONRepresentable: class {
    /**
     Assigns values to a model object from JSON
     
     - parameter jsonObject: JSON object to take values from
     - throws: User specified, used to indicate model object not properly initialized from JSON object
     */
    func read(from jsonObject: MiniJSONObject) throws -> Void
    
    /**
     Assigns values to a JSON object from a model object
     
     - parameter jsonObject: JSON object to write values to
     - throws: User specified, used to indicate JSON object not properly populated from the model object
     */
    func write(to jsonObject: MiniJSONObject) throws -> Void
}

public extension JSONRepresentable {
    func write(to jsonObject: MiniJSONObject) throws -> Void {
        // no-op
    }
    
    @available(*, deprecated: 2.0, renamed: "read(from:)")
    func readFromJSONObject(_ jsonObject: MiniJSONObject) throws -> Void {
        try read(from: jsonObject)
    }
    @available(*, deprecated: 2.0, renamed: "write(to:)")
    func writeToJSONObject(_ jsonObject: MiniJSONObject) throws -> Void {
        try write(to: jsonObject)
    }
}

// MARK: Non-Core Data

/**
 Possible errors for matching a JSON object to a model object
 */
public enum JSONDecoderError: Error {
    
    /**
     Indicates the type in the JSON object and the model object do not match
     
     - parameter key: Key in the JSON object
     - parameter expected: Type expecting in model object
     - parameter actual: Type received in JSON object
     */
    case typeMismatch(key: String, expected: String, actual: String)
    
    /**
     Indicates a merge operation was attempted on a collection of model objects that do not implement `Matchable`.
     
     - parameter key: Key of collection of model objects that does not support `Matchable`.
     - seeAlso: `Matchable`
     */
    case notMatchable(key: String)
    
    /**
     Indicates a relationship was attempted to be formed between Core Data objects and the relationship does not exist
     in Core Data.
     
     - parameter name: Name of the relationship that was attempted.
     */
    case noSuchRelationship(name: String)
    
    /**
     Indicates a Core Data context was not set on a managed transformer.
     */
    case missingContext
    
    /**
     Indicates a Core Data model object was unable to be created.
     */
    case coreDataInstantiationFailed
}

/**
 This is used to indicate how to handle differing collections when fetching non-managed model objects.
 - seeAlso: `ManagedCollectionOperation`
 */
public enum CollectionOperation<T> {
    /**
     Replace the existing collection with the one returned from a data call.
     */
    case replace
    /**
     Update existing items in the collection, remove items not returned, add new items returned.
     */
    case merge(Array<T>?)
    /**
     Update existing items in the collection, add new items returned, do **not** remove existing items not returned.
     */
    case combine(Array<T>?)
}

/**
 Protocol indicating a model object can be matched with a received JSON object.
 */
public protocol Matchable {
    ///
    func isMatch(_ element: MiniJSONObject) -> Bool
}

/**
 Protocol indicating a model object can be instantiated with a JSON object. This is necessary to allow an init of a
 yet-to-be-determined type.
 */
public protocol JSONInstantiable: JSONRepresentable {
    ///
    init()
}

// MARK: Core Data

/**
 This is used to indicate how to handle differing collections when fetching managed model objects.
 - seeAlso: `CollectionOperation`
 */
public enum ManagedCollectionOperation {
    /**
     Update existing items in the collection, remove items not returned, add new items returned.
     */
    case merge
    /**
     Update existing items in the collection, add new items returned, do **not** remove existing items not returned.
     */
    case combine
}

/**
 Indicates a managed model object can be instantianted from a JSON object
 */
public protocol ManagedJSONInstantiable: JSONRepresentable, NSFetchRequestResult {
    /**
     Finds an existing instance in the Core Data context, or creates a new one, that corresponds to the JSON object.
     
     - parameter context: The Core Data context to find/create the instance within
     - parameter jsonObject: The JSON object to use for matching or creating
     - returns: An instance of the matching object or a new instance if no match was found
     */
    static func insertOrFindInstanceInContext(_ context: NSManagedObjectContext, jsonObject: MiniJSONObject) throws -> Self
    
    /**
     Used to determine how to match a JSON object with a managed object
     
     - returns: A tuple of the managed object's key to associate with the JSON object's key if matchable, `nil` otherwise
     */
    static func matchKeys() -> (managedKey: String, jsonKey: String)?
    
    /**
     Used for looking up and creating instances of the managed object.
     
     - returns: The entity name of the type in Core Data.
     */
    static func entityName() -> String
}

public extension ManagedJSONInstantiable {
    
    public static func entityName() -> String {
        let fullClassName = NSStringFromClass(self)
        let components = fullClassName.components(separatedBy: ".")
        
        return components.last!
    }
    
    public static func insertOrFindInstanceInContext(_ context: NSManagedObjectContext, jsonObject: MiniJSONObject) throws -> Self {
        if let (managedKey, jsonKey) = matchKeys(), let jsonValue = jsonObject[jsonKey] {
            let fetchRequest: NSFetchRequest<Self> = NSFetchRequest(entityName: entityName())
            fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: [managedKey, jsonValue])
            
            let results = try? context.fetch(fetchRequest)
            
            if let existing = results?.first {
                return existing
            }
        }
        
        let instance = NSEntityDescription.insertNewObject(forEntityName: Self.entityName(), into: context)
        if let castVal = instance as? Self {
            return castVal
        }
        
        throw JSONDecoderError.coreDataInstantiationFailed
    }
    
}

public extension NSManagedObject {
    /**
     Used to link managed objects after being created from JSON objects.
     
     - parameter relationshipName: The name of the relationship linking `self` with `fromObjects`.
     - parameter fromObjects: The objects to relate to `self`.
     - parameter operation: How existing objects in the relationship should be handled, defaults to `ManagedCollectionOperation.merge`
     - parameter removeObjectsHandlers: A block that allows additional processing of removed objects, defaults to `nil`.
     
     - seeAlso: `ManagedCollectionOperation`
     */
    public func relateObjects<Type>(_ relationshipName: String,
                                    fromObjects: Array<Type>,
                                    operation: ManagedCollectionOperation = .merge,
                                    removedObjectsHandler: ((Array<Type>) -> ())? = nil) throws where Type: NSManagedObject, Type: ManagedJSONInstantiable {
        guard let relationship = self.entity.relationshipsByName[relationshipName],
            let inverseRelationship = relationship.inverseRelationship else {
                throw JSONDecoderError.noSuchRelationship(name: relationshipName)
        }
        
        switch operation {
        case .merge:
            let existing = self.value(forKey: relationshipName)
            let removed: Array<Type> = {
                if let orderedRelationship = existing as? NSOrderedSet, let set = orderedRelationship.set as? Set<Type> {
                    return Array<Type>(set.subtracting(fromObjects))
                } else if let unorderedRelationship = existing as? Set<Type> {
                    return Array<Type>(unorderedRelationship.subtracting(fromObjects))
                }
                return Array<Type>()
            }()
            
            fromObjects.forEach({ (obj: NSManagedObject) -> () in
                obj.setValue(self, forKey: inverseRelationship.name)
            })
            
            removed.forEach({ (obj: NSManagedObject) -> () in
                obj.setValue(nil, forKey: inverseRelationship.name)
            })
            
            if let handler = removedObjectsHandler {
                handler(removed)
            }
        case .combine:
            if let _ = removedObjectsHandler {
                print("Warning: .Combine operation will never yield removed objects.")
            }
            
            fromObjects.forEach({ (obj: NSManagedObject) -> () in
                obj.setValue(self, forKey: inverseRelationship.name)
            })
        }
    }
}

