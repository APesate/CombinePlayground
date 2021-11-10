/*:
[Introduction](Introduction)

# Publishers
`Publisher<Output, Failure>`

A `Publisher` is a protocol that defines an object that can deliver values over time.

It has two associated types:
- Output: type of value that produces.
- Failure: If any, the type of error that could produce.

Can emit three different type of events:
- Ouput: event that provides a value of the associated type defined when declaring the publisher.
- Completion: event that indicates that the publisher fulfilled its purpose and won't emit more events after this one.
- Failure: event that provides an error of the associated type defined when declaring the publisher.

Within the Framework there are a number of convenience publishers:
- Just
- Future
- Deferred
- Empty
- Sequence
- Fail
- Record
- @Published

*/

import Combine

/*:
---
## Convinience Publishers

* Callout(`Just<Output>`):
Provides a single result and terminates.
+ Note: This publisher can't produce an error.
*/

print(beginningOf: "Just Publisher\nJust<Int>")
Just<Int>(5)
	.sink(receiveCompletion: print(event:), receiveValue: print(result:))
printEndOfSection()

/*:
---
* Callout(`Future<Output, Failure>`):
Is initialized with a closure that eventually resolves to a single output value or failure completion. It is ideal for when you want to make a single request, or get a single response, where the API you are using has a completion handler closure.
*/
print(beginningOf: "Future Publisher\nFuture<Int, Error>")
print(subsection: "Future Publisher Success")
Future<Int, PublisherError> { (promise) in
	// At this point you would do some long asynchronous task
	promise(.success(5))
}
.sink(receiveCompletion: print(event:), receiveValue: print(result:))

print(subsection: "Future Publisher Error")

Future<Int, PublisherError> { (promise) in
	// At this point you would do some long asynchronous task
	promise(.failure(.errorExample))
}
.sink(receiveCompletion: print(event:), receiveValue: print(result:))

//: - Note: Future creates and invokes its closure to do the asynchronous request at the time of creation, not when the publisher receives a demand request. This can be counter-intuitive, as many other publishers invoke their closures when they receive demand.

print(subsection: "Demostrate Future Inmediate Execution")
let someFuturePublisher = Future<Int, Never> { (promise) in
	print("Inside of the future publisher")
	promise(.success(5))
}

print("Subscribing to the future publisher")
someFuturePublisher.sink(receiveCompletion: print(event:), receiveValue: print(result:))
printEndOfSection()

/*:
---
* Callout(`Deferred<DeferredPublisher>`):
Waits for a subscriber before running the provided closure to create values for the subscriber. Is useful when creating an API to return a publisher, where creating the publisher is an expensive effort, either computationally or in the time it takes to set up. Deferred holds off on setting up any publisher data structures until a subscription is requested. This provides a means of deferring the setup of the publisher until it is actually needed.
*/

print(beginningOf: "Deferred Publisher\nDeferred<Future<Int, Never>>")
let deferredPublisher = Deferred {
	Future<Int, Never> { (promise) in
		print("Inside of the `Future` publisher")
		promise(.success(5))
	}
}

print("Subscribing to the `Deferred` publisher")
deferredPublisher.sink(receiveCompletion: print(event:), receiveValue: print(result:))
printEndOfSection()

/*:
---
* Callout(`Empty<Output, Error>`):
Never publishes any values, and optionally finishes immediately. Is useful in error handling scenarios where the value is an optional, or where you want to resolve an error by simply not sending anything. Empty can be invoked to be a publisher of any output and failure type combination.
- Note: When subscribed to, an instance of the Empty publisher will not return any values (or errors) and will immediately return a finished completion message to the subscriber.
*/
print(beginningOf: "Empty Publisher\nEmpty<Any, PublisherError>")
Empty<Any, PublisherError>()
	.sink(receiveCompletion: print(event:), receiveValue: print(result:))
printEndOfSection()
/*:
---
* Callout(`Sequence`):
Provides a way to return values as subscribers demand them initialized from a collection.
- Note: If the type within the sequence is denoted as optional, and a nil value is included within the sequence, that will be sent as an instance of the optional type.
*/

print(beginningOf: "Sequence Publisher\nPublisher.Sequence<[Int], Never>")
let sequence = [0, 1, nil, 3, 4]
sequence
	.publisher
	.sink(receiveCompletion: print(event:), receiveValue: print(result:))
printEndOfSection()

/*:
---
* Callout(`Fail<Output, Error>`):
Immediately terminates publishing with the specified failure. Is commonly used when implementing an API that returns a publisher. In the case where you want to return an immediate failure, Fail provides a publisher that immediately triggers a failure on subscription.
*/

print(beginningOf: "Fail Publisher\nFail<Int, PublisherError>")
Fail<Int, PublisherError>(error: .errorExample)
	.sink(receiveCompletion: print(event:), receiveValue: print(result:))
printEndOfSection()

/*:
---
* Callout(`Record<Output, Error>`):
Allows you to create a publisher with pre-recorded values for repeated playback. Record acts very similarly to Publishers.Sequence if you want to publish a sequence of values and then send a .finished completion. It goes beyond that allowing you to specify a .failure completion to be sent from the recording.
- Note: Record does not allow you to control the timing of the values being returned, only the order and the eventual completion following them.
*/
print(beginningOf: "Record Publisher\nRecord<Int, Never>")
let recordPublisher = Record<Int, Never> { recording in
	recording.receive(1)
	recording.receive(2)
	recording.receive(3)
	recording.receive(completion: .finished)
}

recordPublisher
	.sink(receiveCompletion: print(event:), receiveValue: print(result:))
printEndOfSection()

/*:
---
* Callout(`@Published<Value>`):
A property wrapper that adds a Combine publisher to any property.
*/
print(beginningOf: "@Published")
class ExamplePublishedClass {
	@Published var somePublishedVariable: Int = 0
}

let myExampleClass = ExamplePublishedClass()
myExampleClass
	.$somePublishedVariable
	.sink(receiveCompletion: print(event:), receiveValue: print(result:))

myExampleClass.somePublishedVariable = 1
myExampleClass.somePublishedVariable = 2
printEndOfSection()

//: [Next topic: Subscribers](Subscribers)
