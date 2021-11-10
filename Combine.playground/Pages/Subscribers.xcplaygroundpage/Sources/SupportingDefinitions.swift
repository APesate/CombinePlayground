import Foundation
import Combine

public enum SubscriberError: Error {
	case exampleError
}

public var simplePublisher = Just(5)
public var failPublisher = Fail<Int, SubscriberError>(error: .exampleError)
public var publisher = PassthroughSubject<Int, Never>()
