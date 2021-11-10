import Foundation

public enum OperatorError: Error {
	case exampleError
}

public class ObservableClass {
	@Published public var foo = 0

	public init() {}
}

public extension Notification.Name {
	static let exampleNotification = Notification.Name("exampleNotification")
}
