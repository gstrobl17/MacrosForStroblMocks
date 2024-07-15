import Foundation

public protocol DataTaskCreating {

    func createDataTask(with request: URLRequest) -> DataTask

}
