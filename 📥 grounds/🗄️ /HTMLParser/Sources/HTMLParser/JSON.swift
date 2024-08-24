//
//  _jsonCodable.swift
//
//  Created by Cristian Felipe Patiño Rojas on 16/04/2024.
//
import Foundation

// Basado en:
// https://github.com/loudmouth/JSONLookup/blob/master/Sources/JSONLookup/JSONLookup.swift
// https://github.com/saoudrizwan/DynamicJSON
@dynamicMemberLookup
public enum JSON {
    indirect case dict([String: JSON] = [:])
    indirect case array([JSON] = [])
    case bool(Bool)
    case number(Double)
    case string(String)
    case null
}

// MARK: - Codable
extension JSON: Codable {
    
    static let decoder = JSONDecoder()
    static let encoder = JSONEncoder()
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: JSONCodingKeys.self) {
            self = JSON(from: container)
        } else if let container = try? decoder.unkeyedContainer() {
            self = JSON(from: container)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: ""))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        switch self {
        case .null: return
        case .bool(let bool):
            try singleValueContainer.encode(bool)
            
        case .number(let double):
            try singleValueContainer.encode(double)
            
        case .string(let str):
            try singleValueContainer.encode(str)
            
        case .array(let array):
            var unkeyedContainer = encoder.unkeyedContainer()
            try unkeyedContainer.encode(contentsOf: array)
            
        case .dict(let dict):
            var container = encoder.container(keyedBy: JSONCodingKeys.self)
            
            for key in dict.keys {
                let codingKey = JSONCodingKeys(stringValue: key)!
                guard let json = dict[key] else {
                    // Should this encode nil or just pass?
                    try container.encodeNil(forKey: codingKey)
                    continue
                }
                
                switch json {
                case .null: return
                case .bool(let bool):
                    try container.encode(bool, forKey: codingKey)
                    
                case .number(let number):
                    try container.encode(number, forKey: codingKey)
                    
                case .string(let str):
                    try container.encode(str, forKey: codingKey)
                    
                case .array(let jsonArray):
                    try container.encode(jsonArray, forKey: codingKey)
                    
                case .dict(let jsonDict):
                    try container.encode(jsonDict, forKey: codingKey)
                }
            }
        }
    }
    
    internal init(from container: KeyedDecodingContainer<JSONCodingKeys>) {
        var dict: [String: JSON] = [:]
        for key in container.allKeys {
            if let value = try? container.decode(Bool.self, forKey: key) {
                dict[key.stringValue] = .bool(value)
            } else if let value = try? container.decode(Double.self, forKey: key) {
                dict[key.stringValue] = .number(value)
            } else if let value = try? container.decode(String.self, forKey: key) {
                dict[key.stringValue] = .string(value)
            } else if let value = try? container.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key) {
                dict[key.stringValue] = JSON(from: value)
            } else if let value = try? container.nestedUnkeyedContainer(forKey: key) {
                dict[key.stringValue] = JSON(from: value)
            }
        }
        self = .dict(dict)
    }
    
    internal init(from container: UnkeyedDecodingContainer) {
        var container = container
        var arr: [JSON] = []
        while !container.isAtEnd {
            if let value = try? container.decode(Bool.self) {
                arr.append(.bool(value))
            } else if let value = try? container.decode(Double.self) {
                arr.append(.number(value))
            } else if let value = try? container.decode(String.self) {
                arr.append(.string(value))
            } else if let value = try? container.nestedContainer(keyedBy: JSONCodingKeys.self) {
                arr.append(JSON(from: value))
            } else if let value = try? container.nestedUnkeyedContainer() {
                arr.append(JSON(from: value))
            }
        }
        self = .array(arr)
    }
}

// MARK: Suscripts
extension JSON {
    public subscript(index: Int) -> Self? {
        guard case .array(let arr) = self else { return nil }
        return index < arr.count ? arr[index] : nil
    }
    
    public subscript(key: String) -> Self {
        get {
            guard case .dict(let dict) = self else { return .null }
            return dict[key] ?? .null
        }
        set {
            switch self {
            case .dict(var d):
                if case .null = newValue {
                    d[key] = nil
                } else {
                    d[key] = newValue
                }
                self = .dict(d)
            default: break
            }
        }
    }
}

extension JSON {
    enum Error: Swift.Error {
        case wrongURL
    }
}
// MARK: - Inits
extension JSON {
    public init() { self = .dict() }
   
    // @todo: Test
    public init(_ url: String) async throws {
        guard let url = URL(string: url) else { throw Error.wrongURL }
        let (data, _) = try await URLSession.shared.data(from: url)
        self = JSON(data)
    }
    
    /// JSON instantiation using sugar syntax: `JSON { $0.prop = "value" }`
    /// ```
    /// var json = JSON { object in
    ///      object.firstName = "John"
    ///      object.lastNae   = "Doe"
    /// }
    /// ```
    public init(_ block: (inout JSON) -> Void) {
        var mutableJSON = JSON()
        block(&mutableJSON)
        self = mutableJSON
    }
    
    init(data: Data, decoder: JSONDecoder = decoder) throws {
        self = try decoder.decode(Self.self, from: data)
    }
    
    public init(_ object: Any) {
        if let data = object as? Data, let decoded = try? Self.init(data: data) {
            self = decoded
        } else if let dictionary = object as? [String: Any] {
            self = JSON(dictionary.mapValues { JSON($0) })
        } else if let array = object as? [Any] {
            self = JSON.array(array.map { JSON($0) })
        } else if let string = object as? String {
            self = JSON.string(string)
        } else if let bool = object as? Bool {
            self = JSON.bool(bool)
        } else if let number = object as? Double {
            self = JSON.number(number)
        } else if let int = object as? Int {
            self = JSON.number(Double(int))
        } else if let json = object as? JSON {
            self = json
        } else {
            self = JSON.null
        }
    }
}

// MARK: Convenience accessors for better type inference.
extension JSON {
    
    public var array: [JSON] {
        guard case .array(let array) = self else { return [] }
        return array
    }
    
    public var dict: [String: JSON] {
        guard case .dict(let jsonDictionary) = self else { return [:] }
        return jsonDictionary
    }
    
    public var first: Self? { array.first }
    public var last : Self? { array.last  }
    
    
    public var string: String? {
        switch self {
        case .string(let str): return str
        case .number(let dbl): return dbl.description
        case .bool(let bool) : return bool.description
        default: return nil
        }
    }
    
    public var number: NSNumber? {
        if case .number(let double) = self {
            return NSNumber(floatLiteral: double)
        } else if case .bool(let bool) = self {
            return NSNumber(value: bool)
        } else if case .string(let string) = self, let double = Double(string) {
            return NSNumber(value: double)
        }
        return nil
    }
    
    public var double: Double? {
        number?.doubleValue
    }
    
    public var int: Int? {
        number?.intValue
    }
    
    public var bool: Bool? {
        if case .bool(let value) = self {
            return value
        } else if let value = self.number?.boolValue {
            return value
        } else if case .string(let value) = self,
                  (["true", "t", "yes", "y", "1"].contains { value.caseInsensitiveCompare($0) == .orderedSame }) {
            return true
        } else if case .string(let value) = self,
                  (["false", "f", "no", "n", "0"].contains { value.caseInsensitiveCompare($0) == .orderedSame }) {
            return false
        }
        return nil
    }
    
    // Defaults
    public var stringValue: String { string ?? "" }
    public var boolValue: Bool { bool ?? false }
    public var doubleValue: Double { double ?? 0 }
    public var intValue: Int { int ?? 0 }
}


// MARK: - Conformances
extension JSON: Equatable {}
extension JSON: Hashable {}
extension JSON: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.string, .string):
            if let lhsString = lhs.string, let rhsString = rhs.string {
                return lhsString < rhsString
            }
            return false
        case (.number, .number):
            if let lhsNumber = lhs.number, let rhsNumber = rhs.number {
                return lhsNumber.doubleValue < rhsNumber.doubleValue
            }
            return false
        default: return false
        }
    }
}


// MARK: - Literals
/// Literals conformance so we can instantiate a JSON from primitive types
/// ```
/// var string: JSON = "value" // .string("value")
/// var int   : JSON = 0       // .number(0)
/// var bool  : JSON = true    // .bool(true)
/// var double: JSON = 30.0    // .number(30.0)
/// ```
extension JSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        let dictionary = elements.reduce(into: [String: Any](), { $0[$1.0] = $1.1})
        self.init(dictionary)
    }
}

extension JSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}

extension JSON: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = .string(value)
    }
    
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension JSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(value)
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(Double(value))
    }
}

extension JSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

// MARK: - Dynamic lookup accessors
extension JSON {
    
    /**
     Dynamic subscript so we can use dot syntax to access/set properties:
     
     `let title: JSON = json.title`
     `json.title = .string("Some title")`
     */
    public subscript(dynamicMember member: String) -> Self {
        get { self[member] }
        set { self[member] = newValue }
    }
    
    /**
     Complementary dynamic suscripts so we have type interference with default values:

     ```
     let movie = JSON {
        $0.id = 1
        $0.title = "Groundhog Day"
        $0.isFavorite = true
     }
     
     func fetchDetail(_ int: Int)
     func heartView(_ isFavorite: Bool) -> some View ...
     func heading(_ title: String) -> some View ...
     
     fetchDetail(movie.id)
     heartView(movie.isFavorite)
     heading(movie.title)
     ```
     
     Overlaod disfavoried so they don't interfere with equatable usage coupled with default subscript.
     
     Otherwise, this won't work  as compiler wouldn't now which dynamic subscript to use.
     
     ```
     ForEach(movies, id: \.id.intValue) { movie in
        Cell(movie)
            .padding(.leading , movie.id == movies.last.id ? 16 : 0)
            .padding(.trailing, movie.id == movies.last.id ? 16 : 0)
     }
     ```
     */
    
    @_disfavoredOverload
    public subscript(dynamicMember member: String) -> [Self] {
        self[member].array
    }
    
    @_disfavoredOverload
    public subscript(dynamicMember member: String) -> String {
        self[member].stringValue
    }
    
    @_disfavoredOverload
    public subscript(dynamicMember member: String) -> Bool {
        self[member].boolValue
    }
    
    @_disfavoredOverload
    public subscript(dynamicMember member: String) -> Double {
        self[member].doubleValue
    }
   
    @_disfavoredOverload
    public subscript(dynamicMember member: String) -> Int {
        self[member].intValue
    }
}


// MARK: - Coding keys
internal struct JSONCodingKeys: CodingKey {
    internal var stringValue: String
    
    internal init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    internal var intValue: Int?
    
    internal init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

// MARK: - Pretty Print
extension JSON: CustomStringConvertible, CustomDebugStringConvertible {
    public var object: Any {
        get {
            switch self {
            case .dict(let value): return value.mapValues { $0.object }
            case .array(let value): return value.map { $0.object }
            case .string(let value): return value
            case .number(let value): return value
            case .bool(let value): return value
            case .null: return NSNull()
            }
        }
    }
    
    public var description: String {
        return String(describing: self.object as AnyObject).replacingOccurrences(of: ";\n", with: "\n")
    }
    
    public var debugDescription: String {
        return description
    }
}

/**
  Protocol so we can instantiate objects whose value is stored in a reference.
 
  Because of limitations on type inference:
 
  This works: `json.someValue = "in place value"`
 
  But this won't: `json.someValue = someVariable`
 
  So we will want to have a helper: `json.someValue = someVariable.json()`
 
  ```
  func person(id: Int, name: String, age: Int) -> JSON {
      JSON { json in
          json.id = id.json()
          json.name = name.json()
          json.age = age.json()
      }
  }
  ```
 */
protocol JSONConvertible {
    func json() -> JSON
}

extension JSONConvertible {
    func json() -> JSON {
        JSON(self)
    }
}

extension String: JSONConvertible {}
extension Double: JSONConvertible {}
extension Bool: JSONConvertible {}
extension Int: JSONConvertible {}
