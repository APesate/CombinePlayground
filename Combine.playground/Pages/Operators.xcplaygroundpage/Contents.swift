/*:
[Previous Topic: Subscribers](Subscribers)

# Operators
 An `Operator` is a function that creates either a Publisher or a Subscriber to react upon the elements it receives. That means that it can either emit or receive events.

You can create chains of these together, for processing, reacting, and transforming the data provided by a publisher, and requested by the subscriber, on both the Output and Failure type.

For a full list of the available operators please refer to the [`Publisher` documentation](https://developer.apple.com/documentation/combine/publisher)
*/

import Combine
import Foundation
import PlaygroundSupport

// Needed to demonstrate how some async operators work
PlaygroundPage.current.needsIndefiniteExecution = true
// Set to collect all the Subscriptions used in the example
var cancellables: Set<AnyCancellable> = []

/*:
* Callout(Filter):
Passes through all instances of the output type that match a provided closure, dropping any that doesn't match.
*/
print(beginningOf: "Basic Operators")
print(subsection: "Filter")
(0...10)
	.publisher
	.filter({ $0 % 2 == 0 })
	.sink(receiveCompletion: print(event:), receiveValue: print(result:))
  .store(in: &cancellables)

/*:
* Callout(Map):
Most commonly used to convert one data type into another along a pipeline.
*/
print(subsection: "Map")
Just<Int>(2)
	.map({ "Is an even number? -> \($0 % 2 == 0) " })
	.sink(receiveCompletion: print(event:), receiveValue: print(result:))
  .store(in: &cancellables)

/*:
* Callout(AllSatisfy):
A publisher that publishes a single Boolean value that indicates whether all received elements match against a provided predicate.
*/
print(subsection: "AllSatisfy")
(0...10)
	.publisher
	.allSatisfy({ $0 % 2 == 0 })
	.sink(receiveCompletion: print(event:), receiveValue: print(result:))
  .store(in: &cancellables)

/*:
* Callout(Throttle):
Constrains the stream to publishing zero or one value within a specified time window, independent of the number of elements provided by the publisher.
*/
print(subsection: "Throttle")

let throttleClass = ObservableClass()
throttleClass.$foo
	.throttle(for: 0.5, scheduler: DispatchQueue.global(), latest: false)
	.sink(receiveCompletion: print(event:), receiveValue: print(result:))
	.store(in: &cancellables)

DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) { // 0.1
	throttleClass.foo = 1
	DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) { // 0.3
		throttleClass.foo = 2
		DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) { // 0.4
			throttleClass.foo = 3
      DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) { // 0.6
        throttleClass.foo = 4
      }
		}
	}
}

sleep(2)

/*:
* Callout(Debounce):
Collapses multiple values within a specified time window into a single value
*/
print(subsection: "Debounce")

NotificationCenter.default
	.publisher(for: Notification.Name.exampleNotification)
	.receive(on: DispatchQueue.global())
	.debounce(for: 0.5, scheduler: DispatchQueue.global())
	.sink(receiveCompletion: print(event:), receiveValue: print(result:))
	.store(in: &cancellables)

DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
	NotificationCenter.default.post(name: .exampleNotification, object: nil, userInfo: ["value": 0])
	DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
		NotificationCenter.default.post(name: .exampleNotification, object: nil, userInfo: ["value": 1])
		DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
			NotificationCenter.default.post(name: .exampleNotification, object: nil, userInfo: ["value": 2])
		}
	}
}

sleep(1)

/*:
* Callout(Merge):
Takes two upstream publishers and mixes the elements published into a single pipeline as they are received.
*/
print(subsection: "Merge")
let pub1 = Just(true)
let pub2 = Future<Bool, Never> { (promise) in
	DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
		promise(.success(false))
	}
}

Publishers
	.Merge(pub1, pub2)
	.receive(on: DispatchQueue.global())
	.sink(receiveValue: print(result:))
  .store(in: &cancellables)

sleep(1)

/*:
* Callout(CombineLatest):
Merges two pipelines into a single output, converting the output type to a tuple of values from the upstream pipelines, and providing an update when any of the upstream publishers provide a new value.
*/
print(subsection: "CombineLatest")
let combineSubject1 = CurrentValueSubject<Bool, Never>(true)
let combineSubject2 = CurrentValueSubject<Bool, Never>(true)

combineSubject1
	.combineLatest(combineSubject2) { (lhs, rhs) -> Bool in
		return lhs && rhs
	}
	.sink(receiveValue: print(result:))
  .store(in: &cancellables)

print(note: "Sending `false` on `combineSubject2`")
combineSubject2.send(false)
print(note: "Sending `true` on `combineSubject2`")
combineSubject2.send(true)

/*:
* Callout(Catch):
Handles errors (completion messages of type .failure) from an upstream publisher by replacing the failed publisher with another publisher.
*/
print(subsection: "Catch")
let catchSubject = PassthroughSubject<Int, OperatorError>()

catchSubject
	.tryMap({ value in
		if value < 0 { throw OperatorError.exampleError }
		return value
	})
	.catch { (error) -> AnyPublisher<Int, OperatorError> in
		print(note: "An error was detected: \(error). Send nothing instead.")
		return Empty<Int, OperatorError>().eraseToAnyPublisher()
	}
	.sink(receiveCompletion: print(event:), receiveValue: print(result:))
	.store(in: &cancellables)

print(note: "Sending value 3")
catchSubject.send(3)
print(note: "Sending value 10")
catchSubject.send(10)
print(note: "Sending value -1")
catchSubject.send(-1)

printEndOfSection()

/*:
---
* Callout(Publisher Data Type Transformation):
By chaining operators you can transform the Output and Failure types.
*/
print(beginningOf: "Type Transformation")

print(note: "Defining initial publisher")
let initialPublisher = (0...10)
	.publisher
print(type(of: initialPublisher))

print(note: "End publisher after chaining multiple operators")
let chainedPublisher = initialPublisher
	.filter({ $0 % 2 == 0 })
	.count()
	.map({ "The amount of even numbers in the sequence is: \($0)" })

print(type(of: chainedPublisher))

print(note: "Adding a subscriber")
chainedPublisher
	.sink(receiveCompletion: print(event:), receiveValue: print(result:))
  .store(in: &cancellables)
printEndOfSection()

/*:
---
* Callout(Type-Erased):
Use this when you want to hide the complexity that builds up from chained operators.
*/
print(beginningOf: "Type-Erase")
print(note: "Defining initial publisher")
let futurePublisher = Future<Int, Error> { (promise) in
	promise(.success(5))
}
print(typeOf: futurePublisher)

print(note: "Applying the `AllSatisfy` operator")
let allSatisfyPublisher = futurePublisher.allSatisfy({ $0 % 2 == 0 })
print(typeOf: allSatisfyPublisher)

print(note: "Applying the `Map` operator")
let mapPublisher = allSatisfyPublisher.map { (result) -> String in
	if result {
		return "Is an even number"
	} else {
		return "Is an odd number"
	}
}
print(typeOf: mapPublisher)

print(note: "Erasing to AnyPublisher")
let anyPublisher = mapPublisher.eraseToAnyPublisher()
print(typeOf: anyPublisher)

print(note: "Adding a subscriber")
anyPublisher
	.sink(receiveCompletion: print(event:), receiveValue: print(result:))
  .store(in: &cancellables)

//: [Next Topic: Subjects](Subjects)
