import Combine

public func print(beginningOf section: String) {
	print(String(repeating: "-", count: section.count))
	print(section)
	print(String(repeating: "-", count: section.count))
}

public func print(subsection: String) {
	print("\n* \(subsection)")
}

public func print(note: String) {
	print("- \(note) -")
}

public func printEndOfSection() {
	print("\n")
}

public func print(result: Any) {
	print("Output: \(result)")
}

public func print(typeOf object: Any) {
	print("Object Type: " + String(describing: object))
}

public func print<Failure>(event: Subscribers.Completion<Failure>) {
	switch event {
		case .failure(let error):
			print("Completion Event received of type `Failure`. Error: \(error)")
		case .finished:
			print("Completion Event received of type `Finished`")
	}
}
