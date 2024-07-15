import Foundation

public protocol DateCreating {
    
    var now: Date { get }
    func date(timeIntervalSinceNow: TimeInterval) -> Date
    
}
