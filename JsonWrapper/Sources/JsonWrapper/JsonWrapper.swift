import Foundation
import CxxJsonParser

public final class JsonDocument {
    private let handle: OpaquePointer
    
    public init(json: String) throws {
        guard let handle = json_document_create(json) else {
            let errorMessage = Self.getLastError() ?? "Unknown parse error"
            throw JsonError.parseError(errorMessage)
        }
        self.handle = handle
    }
    
    deinit {
        json_document_free(handle)
    }
    
    public func getString(key: String) -> String? {
        guard let cString = json_get_string(handle, key) else {
            return nil
        }
        let result = String(cString: cString)
        free_string(cString)
        return result
    }
    
    public func getInt(key: String) -> Int64? {
        var value: Int64 = 0
        let success = json_get_int(handle, key, &value)
        return success ? value : nil
    }
    
    public func getDouble(key: String) -> Double? {
        var value: Double = 0
        let success = json_get_double(handle, key, &value)
        return success ? value : nil
    }
    
    public func getBool(key: String) -> Bool? {
        var value: Bool = false
        let success = json_get_bool(handle, key, &value)
        return success ? value : nil
    }
    
    public func hasKey(_ key: String) -> Bool {
        return json_has_key(handle, key)
    }
    
    private static func getLastError() -> String? {
        guard let cString = json_get_last_error() else {
            return nil
        }
        let result = String(cString: cString)
        free_string(cString)
        return result
    }
}

public enum JsonParser {
    public static func getString(from json: String, key: String) -> String? {
        guard let cString = json_parse_get_string(json, key) else {
            return nil
        }
        let result = String(cString: cString)
        free_string(cString)
        return result
    }
    
    public static func parse(_ json: String) -> JsonDocument? {
        return try? JsonDocument(json: json)
    }
}

public enum JsonError: Error, LocalizedError {
    case parseError(String)
    case keyNotFound(String)
    case typeMismatch(key: String, expected: String)
    
    public var errorDescription: String? {
        switch self {
        case .parseError(let message):
            return "JSON parse error: \(message)"
        case .keyNotFound(let key):
            return "Key not found: \(key)"
        case .typeMismatch(let key, let expected):
            return "Type mismatch for key '\(key)': expected \(expected)"
        }
    }
}

extension JsonDocument {
    public subscript(key: String) -> String? {
        return getString(key: key)
    }
}
