import Foundation

public struct DateFactory {
    public init() { }
}

extension DateFactory: DateCreating {
    
    public var now: Date {
        return Date()
    }
    
    public func date(timeIntervalSinceNow interval: TimeInterval) -> Date {
        return Date(timeIntervalSinceNow: interval)
    }
    
}
