import Foundation

public protocol Semaphore {
    
    func signal() -> Int
    func wait()

}
