import CoreData

/**
 Represents JSON objects. Can be accessed similarly to a dictionary (like a JSON object).
 */
public class MiniJSONObject {
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        formatter.isLenient = true
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    /**
     Date format to be used for timestamps. Defaults to ISO-8601.
     */
    public static var dateFormat: String {
        get {
            return dateFormatter.dateFormat
        }
        set(newFormat) {
            dateFormatter.dateFormat = newFormat
        }
    }
    
    /**
     All of the data from decoding from JSON
     */
    public var data: Dictionary<String, Any>
    
    public init() {
        data = [:]
    }
    
    /**
     Create a JSON object with an initial set of values
     
     - parameter values: Dictionary of key-values to store in `data`.
     */
    public init(values: Dictionary<String, Any>) {
        data = values
    }
    
    /**
     Access the JSON data.
     
     - parameter key: The JSON key for the value.
     
     - returns: A nested `JSONObject` dictionary, `JSONObject` array, a primitive value, or `nil` if nothing found.
     */
    public subscript(key: String) -> Any? {
        guard let value = data[key] else {
            return nil
        }
        
        if let dictVal = value as? Dictionary<String, Any> {
            return MiniJSONObject(values: dictVal)
        } else if let arrayValue = value as? Array<Dictionary<String, Any>>, arrayValue.count > 0 {
            return arrayValue.map({ (jsonDict) -> MiniJSONObject in
                return MiniJSONObject(values: jsonDict)
            })
        }
        
        return value
    }
    
    // MARK: - POSO Decoders
    
    /**
     Decodes an array of model objects that conform to `JSONInstantiable` and `Matchable`.
     
     - parameter key: Key of the value requested.
     
     - returns: An array of model objects or `nil` if not found.
     */
    public func decode<T>(_ key: String) throws -> Array<T>? where T: JSONInstantiable, T: Matchable {
        return try decode(key, defaultValue: nil, operation: .replace)
    }
    
    /**
     Decodes an array of model objects that conform to `JSONInstantiable` and `Matchable`.
     
     - parameter key: Key of the value requested.
     - parameter defaultValue: Value to use if no value found for key.
     - parameter operation: How to handle differing values, defaults to `CollectionOperation.replace`.
     
     - returns: An array of model objects, or `nil` if not found and no `defaultValue` was provided.
     
     - seeAlso: `CollectionOperation`
     */
    public func decode<T>(_ key: String,
                          defaultValue: Array<T>? = nil,
                          operation: CollectionOperation<T> = .replace) throws -> Array<T>? where T: JSONInstantiable, T: Matchable {
        guard let value = self[key] else {
            return defaultValue
        }
        
        if value is NSNull {
            return nil
        }
        
        guard var array = value as? Array<MiniJSONObject> else {
            throw JSONDecoderError.typeMismatch(key: key, expected: "Array", actual: "\(type(of: value))")
        }
        
        switch operation {
        case .replace:
            return try array.map({
                try $0.transform()
            }) as Array<T>
        case .combine(let combineWith):
            var existing: Array<T> = combineWith ?? []
            
            for (index, obj) in array.enumerated() {
                if let idx = existing.index(where: { $0.isMatch(obj) }) {
                    try existing[idx].read(from: obj)
                    array.remove(at: index)
                }
            }
            
            existing.append(contentsOf: try array.map {
                try $0.transform()
                })
            
            return existing
        case .merge(let mergeWith):
            let existingArray: Array<T> = mergeWith ?? []
            
            var filtered = try existingArray.filter { existing -> Bool in
                for (index, obj) in array.enumerated() {
                    if existing.isMatch(obj) {
                        try existing.read(from: obj)
                        array.remove(at: index)
                        return true
                    }
                }
                return false
            }
            
            filtered.append(contentsOf: try array.map({
                try $0.transform()
            }))
            
            return filtered
        }
    }
    
    /**
     Decodes an array of model objects that conform to `JSONInstantiable`.
     
     - parameter key: Key of the value requested.
     
     - returns: An array of model objects, or `nil` if not found.
     
     - seeAlso: `CollectionOperation`
     */
    public func decode<T: JSONInstantiable>(_ key: String) throws -> Array<T>? {
        return try decode(key, defaultValue: nil, operation: .replace)
    }
    
    /**
     Decodes an array of model objects that conform to `JSONInstantiable`.
     
     - parameter key: Key of the value requested.
     - parameter defaultValue: Value to use if no value found for key.
     - parameter operation: How to handle differing values, defaults to `CollectionOperation.replace`. **Supplying**
     `.merge` **with this function is not supported.**
     
     - returns: An array of model objects, or `nil` if not found and no `defaultValue` was provided.
     
     - seeAlso: `CollectionOperation`
     */
    public func decode<T: JSONInstantiable>(_ key: String,
                                            defaultValue: Array<T>? = nil,
                                            operation: CollectionOperation<T> = .replace) throws -> Array<T>? {
        guard let value = self[key] else {
            return defaultValue
        }
        
        if value is NSNull {
            return nil
        }
        
        guard let array = value as? Array<MiniJSONObject> else {
            throw JSONDecoderError.typeMismatch(key: key, expected: "Array", actual: "\(type(of: value))")
        }
        
        switch operation {
        case .replace:
            return try array.map {
                try $0.transform()
            }
        case .combine(let input):
            var existing: Array<T> = input ?? []
            existing.append(contentsOf: try array.map {
                try $0.transform()
                })
            
            return existing
        case .merge(_):
            throw JSONDecoderError.notMatchable(key: key)
        }
    }
    
    /**
     Decodes a model object that conform to `JSONInstantiable`.
     
     - parameter key: Key of the value requested.
     - parameter defaultValue: Value to use if no value found for key.
     
     - returns: A model object, or `nil` if not found and no `defaultValue` was provided.
     */
    public func decode<T: JSONInstantiable>(_ key: String, defaultValue: T? = nil) throws -> T? {
        guard let value = self[key] else {
            return defaultValue
        }
        
        if value is NSNull {
            return nil
        }
        
        guard let castValue = value as? MiniJSONObject else {
            throw JSONDecoderError.typeMismatch(key: key, expected: "JSONObject", actual: "\(type(of: value))")
        }
        
        return try castValue.transform() as T
    }
    
    /**
     Decodes a JSON primitive (String, Int, Boolean, etc.)
     
     - parameter key: Key of the value requested.
     - parameter defaultValue: Value to use if no value found for key.
     
     - returns: A primitive object, or `nil` if not found and no `defaultValue` was provided.
     */
    public func decode<T>(_ key: String, defaultValue: T? = nil) throws -> T? {
        guard let value = self[key] else {
            return defaultValue
        }
        
        if value is NSNull {
            return nil
        }
        
        if let numberValue = value as? NSNumber, let extractedValue = extract(numberValue, forType: T.self) {
            return extractedValue
        }
        
        guard let castValue = value as? T else {
            throw JSONDecoderError.typeMismatch(key: key, expected: "\(T.self)", actual: "\(type(of: value))")
        }
        
        return castValue
    }
    
    internal func extract<T>(_ number: NSNumber, forType type: T.Type) -> T? {
        if type == Int.self {
            return number.intValue as? T
        } else if type == UInt.self {
            return number.uintValue as? T
        } else if type == Int8.self {
            return number.int8Value as? T
        } else if type == UInt8.self {
            return number.uint8Value as? T
        } else if type == Int16.self {
            return number.int16Value as? T
        } else if type == UInt16.self {
            return number.uint16Value as? T
        } else if type == Int32.self {
            return number.int32Value as? T
        } else if type == UInt32.self {
            return number.uint32Value as? T
        } else if type == Int64.self {
            return number.int64Value as? T
        } else if type == UInt64.self {
            return number.uint64Value as? T
        } else if type == Float.self {
            return number.floatValue as? T
        } else if type == Double.self {
            return number.doubleValue as? T
        } else if type == Bool.self {
            return number.boolValue as? T
        } else {
            return nil
        }
    }
    
    /**
     Decodes a date according to the `dateFormat` set.
     
     - parameter key: Key of the value requested.
     - parameter defaultValue: Value to use if no value found for key.
     
     - returns: A `Date` object, or `nil` if not found and no `defaultValue` was provided.
     
     - seeAlso: `JSONObject.dateFormat`
     */
    public func decode(_ key: String, defaultValue: Date? = nil) throws -> Date? {
        guard let value = self[key] else {
            return defaultValue
        }
        
        guard let valueString = value as? String else {
            return nil
        }
        
        guard let dateValue = MiniJSONObject.dateFormatter.date(from: valueString) else {
            return defaultValue
        }
        
        return dateValue
    }
    
    // MARK: - POSO Encoders
    
    /**
     Encodes a collection type of `JSONRepresentable` model objects as an array.
     
     - parameter value: Collection of model objects.
     - parameter key: Key to associate the value array with.
     - parameter defaultValue: Value to use in lieu of `value` if it is `nil`.
     */
    public func encode<T: Collection>(_ value: T?, forKey: String,
                                      defaultValue: T? = nil) throws -> Void where T.Iterator.Element: JSONRepresentable {
        guard let val = value else {
            if let defaultValue = defaultValue {
                try encode(defaultValue, forKey: forKey)
            }
            return
        }
        
        let mappedData: Array<Dictionary<String, Any>> = try val.map { v in
            let json = MiniJSONObject()
            try v.write(to: json)
            return json.data
        }
        data[forKey] = mappedData
    }
    
    /**
     Encodes a `JSONRepresentable` model object.
     
     - parameter value: Model object.
     - parameter key: Key to associate the value array with.
     - parameter defaultValue: Value to use in lieu of `value` if it is `nil`.
     */
    public func encode<T: JSONRepresentable>(_ value: T?, forKey: String, defaultValue: T? = nil) throws -> Void {
        guard let val = value else {
            if let defaultValue = defaultValue {
                try encode(defaultValue, forKey: forKey)
            }
            return
        }
        
        let json = MiniJSONObject()
        try val.write(to: json)
        data[forKey] = json.data
    }
    
    /**
     Encodes a JSON primitive (String, Int, Boolean, etc.)
     
     - parameter value: JSON primitive object.
     - parameter key: Key to associate the value array with.
     - parameter defaultValue: Value to use in lieu of `value` if it is `nil`.
     */
    public func encode<T>(_ value: T?, forKey: String, defaultValue: T? = nil) -> Void {
        guard let val = value else {
            if let defaultValue = defaultValue {
                encode(defaultValue, forKey: forKey)
            }
            return
        }
        
        self.data[forKey] = val
    }
    
    /**
     Encodes a `Date` according to the `dateFormat`
     
     - parameter value: `Date` object.
     - parameter key: Key to associate the value array with.
     - parameter defaultValue: Value to use in lieu of `value` if it is `nil`.
     
     - seeAlso: `JSONObject.dateFormat`
     */
    public func encode(_ value: Date?, forKey: String, defaultValue: Date? = nil) {
        guard let val = value else {
            if let defaultValue = defaultValue {
                encode(defaultValue, forKey: forKey)
            }
            return
        }
        
        self.data[forKey] = MiniJSONObject.dateFormatter.string(from: val)
    }
    
    // MARK: - Core Data Decoders
    
    /**
     Decodes an array of managed model objects.
     
     - parameter key: Key of the value requested.
     - parameter context: The Core Data context to associate the model object with.
     - parameter defaultValue: Value to use if no value found for `key`.
     
     - returns: An array of core data managed model objects, or `nil` if none found and no `defaultValue` is provided.
     */
    public func decode<T: ManagedJSONInstantiable>(_ key: String, context: NSManagedObjectContext, defaultValue: Array<T>? = nil) throws -> Array<T>? {
        if let val = self[key] {
            if let array = val as? Array<MiniJSONObject> {
                return try array.map {json in
                    return try json.transform(context) as T
                    } as Array<T>
            } else if val is NSNull {
                return nil
            }
            throw JSONDecoderError.typeMismatch(key: key, expected: "Array", actual: "\(type(of: val))")
        }
        
        return defaultValue
    }
    
    /**
     Decodes a managed model object.
     
     - parameter key: Key of the value requested.
     - parameter context: The Core Data context to associate the model object with.
     - parameter defaultValue: Value to use if no value found for `key`.
     
     - returns: A core data managed model object, or `nil` if not found and no `defaultValue` is provided.
     */
    public func decode<T: ManagedJSONInstantiable>(_ key: String, context: NSManagedObjectContext, defaultValue: T? = nil) throws -> T? {
        if let val = self[key] {
            if let castVal = val as? MiniJSONObject {
                return try castVal.transform(context) as T
            } else if val is NSNull {
                return nil
            }
            throw JSONDecoderError.typeMismatch(key: key, expected: "JSONObject", actual: "\(type(of: val))")
        }
        
        return defaultValue
    }
    
    // MARK: - Transform
    
    private func transform<Type: JSONInstantiable>() throws -> Type {
        let t = Type()
        try t.read(from: self)
        return t
    }
    
    private func transform<Type: ManagedJSONInstantiable>(_ context: NSManagedObjectContext) throws -> Type {
        let t = try Type.insertOrFindInstanceInContext(context, jsonObject: self)
        try t.read(from: self)
        return t
    }
}
