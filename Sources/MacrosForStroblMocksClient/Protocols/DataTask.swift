import Foundation

// Mirrors the minimally required elements from the URLSessionTask protocol
public protocol DataTask: NSObjectProtocol {

    func cancel()
    func resume()

}
