import Foundation

public protocol JSONEncoding {
    func encode<T>(_ value: T) throws -> Data where T: Encodable
}
