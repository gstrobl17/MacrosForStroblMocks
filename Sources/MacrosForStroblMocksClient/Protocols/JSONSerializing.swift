import Foundation

public protocol JSONSerializing {
    static func data(withJSONObject obj: Any, options opt: JSONSerialization.WritingOptions) throws -> Data
    static func jsonObject(with data: Data, options opt: JSONSerialization.ReadingOptions) throws -> Any
}

extension JSONSerializing {
    public static func data(withJSONObject obj: Any) throws -> Data {
        try data(withJSONObject: obj, options: [])
    }
    
    public static func jsonObject(with data: Data) throws -> Any {
        return try jsonObject(with: data, options: [])
    }
}
