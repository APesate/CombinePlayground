/*:
[Previous Topic: Publishers](Publishers)

# Subscribers
`Subscriber<Input, Failure>`

A `Subscriber` is a protocol that defines an object that can receive a stream of elements from a Publisher, along with life cycle events describing changes to their relationship.

It has two associated types:
- Input: type of value that can receive.
- Failure: If any, the type of error that could receive.

There are two subscribers built-in to Combine:
- Sink
- Assign

- Note: A given subscriber’s Input and Failure associated types must match the Output and Failure of its corresponding publisher.
*/
import Combine
/*:---
## Built-in Subscribers

* Callout(`Sink<Input, Failure>`):
Creates an all-purpose subscriber.
*/
print(beginningOf: "Sink Subscriber")
print(subsection: "Subscribe only to output events")
simplePublisher
	.sink(receiveValue: { (output) in
		print(result: output)
	})

print(subsection: "Subscribe to all events")
simplePublisher
	.sink(receiveCompletion: { (completionEvent) in
		print(event: completionEvent)

		switch completionEvent {
			case .failure(let error):
				print("Error: \(error).")

			case .finished:
				print("The publisher did terminate.")

		}
	}, receiveValue: { (output) in
		print(result: output)
	})

printEndOfSection()

/*:
---
* Callout(`Assign<Input, Never>`):
Creates a subscriber used to update a property on a KVO compliant object.
- Note: Only handles data, and expects all errors or failures to be handled in the pipeline before it is invoked.
+ Note: The type of `KeyPath` required for the assign operator is important. It requires a `ReferenceWritableKeyPath`, which is different from both `WritableKeyPath` and `KeyPath`.
*/

print(beginningOf: "Assign Subscriber")
class SomeClass {
	var foo: Int = 0 {
		didSet {
			print("The value of `foo` changed from `\(oldValue)` to `\(foo)`")
		}
	}
}

let myClass = SomeClass()
print("Initial value of the `foo`: \(myClass.foo)")
print(note: "Binding subscription to the publisher.")
simplePublisher
	.assign(to: \.foo, on: myClass)
printEndOfSection()

/*:
---
# Cancellables

A protocol indicating that an activity or action supports cancellation.

Subscribers can support cancellation, which terminates a subscription and shuts down all the stream processing prior to any Completion sent by the publisher. Both Assign and Sink conform to the `Cancellable protocol`. Calling `cancel() `frees up any allocated resources.

- Important: When you are storing a reference to your own subscriber in order to clean up later, you generally want a reference to cancel the subscription. `AnyCancellable` provides a type-erased reference that converts any subscriber to the type `AnyCancellable`, allowing the use of `.cancel()` on that reference, but not access to the subscription itself (which could, for instance, request more data). It is important to store a reference to the subscriber, as when the reference is deallocated it will implicitly cancel its operation.
*/

print(beginningOf: "Cancellable")
print(subsection: "Manual Cancelling")

print("Binding the subscription")
let cancellable = publisher
	.sink(receiveValue: print(result:))
publisher.send(0)
publisher.send(1)
print("Canceling the subscription")
cancellable.cancel()
print("The publisher sent another value after the cancelation which was not received.")
publisher.send(2)

printEndOfSection()

//: A pattern that is supported with Combine is collecting `AnyCancellable` references into a set and then saving references to the cancellable subscribers with a `store` method.

print(subsection: "Automatic Cancelling")

var cancellables: Set<AnyCancellable> = []

print("Binding the subscription")
publisher
	.sink(receiveValue: print(result:))
	.store(in: &cancellables)
publisher.send(0)
publisher.send(1)
print("Deallocating the `cancellables` container.")
cancellables.removeAll()
print("The publisher sent another value after the cancelation which was not received.")
publisher.send(2)

printEndOfSection()

//: [Next Topic: Operators](Operators)
