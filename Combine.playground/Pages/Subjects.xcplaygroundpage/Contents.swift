/*:
[Previous Topic: Operators](Operators)

# Subjects
`protocol Subject : AnyObject, Publisher`

A `Subject` is a publisher that you can use to ”inject” values into a stream, by calling its `send(_:)` method. This can be useful for adapting existing imperative code to the Combine model. If multiple subscribers are connected to a subject, it will fan out values to the multiple subscribers when `send(_:)` is invoked.

There are two built-in subjects in Combine:
- CurrentValueSubject
- PassthroughSubject
*/

import Combine

var cancellables: Set<AnyCancellable> = []

//: ## Built-in Subjects
/*:
---
* Callout(`CurrentValueSubject<Output, Failure>`):
A publisher that maintains a buffer of the most recently published element.\
**CurrentValueSubject** remembers the current value so that when a subscriber is attached, it immediately receives the current value. When a subscriber is connected and requests data, the initial value is sent. Further calls to `.send(_:)` afterwards will then pass through values to any subscribers.
*/

print(beginningOf: "CurrentValueSubject<Int, Never>")
let initialValue = 5

print(note: "Setting up the subject with an initial value of \(initialValue)")

let currentValueSubject = CurrentValueSubject<Int, Never>(initialValue)

//: - Note: When adding a subscriber to a `CurrentValueSubject`, this will always advertise its current value upon demanding.
print(note:"Adding a subscriber")
currentValueSubject
	.sink(receiveValue: { print("Subs1 - Output: \($0)") })
	.store(in: &cancellables)

print(subsection: "Setting the value of the `subject` through its `value` property.")
currentValueSubject.value = 10

//: - Note: Because now the value of the `subject` is 10 the next subscriber will receive that value as the initial one.
print(note:"Adding another subscriber")
currentValueSubject
	.sink(receiveValue: { print("Subs2 - Output: \($0)") })
	.store(in: &cancellables)

//: - Note: The same happens when using the `send(_:)` method. When adding another subscriber it will receive this as the initial value.
print(subsection: "Setting the value of the `subject` through its `send(_:)` method.")
currentValueSubject.send(15)

print(note:"Adding another subscriber")
currentValueSubject
	.sink(receiveValue: { print("Subs3 - Output: \($0)") })
	.store(in: &cancellables)

printEndOfSection()

/*:
* Important: Demostrate completion of a CurrentValueSubject
*/

print(beginningOf: "CurrentValueSubject<Int, SubjectError>")
let completableCurrentValueSubject = CurrentValueSubject<Int, SubjectError>(0)

print(note:"Adding a subscription")
completableCurrentValueSubject
	.sink(receiveCompletion: print(event:), receiveValue: print(result:))
	.store(in: &cancellables)

print(note: "Passing down value 1")
completableCurrentValueSubject.send(1)

print(note: "Passing down `.failure(_)` completion event")
completableCurrentValueSubject.send(completion: .failure(.exampleError))

//: - Note: This next `send(_:)` event will not be emitted.
print(note: "Passing down value 2")
completableCurrentValueSubject.send(2)

printEndOfSection()

/*:
---
* Callout(`PassthroughSubject<Output, Failure>`):
A publisher that broadcasts elements to downstream subscribers.\
Unlike **CurrentValueSubject**, a **PassthroughSubject** doesn’t have an initial value or a buffer of the most recently-published element. When a subscriber is connected and requests data, it will not receive any values until a `.send(_:)` call is invoked.
*/
print(beginningOf: "PassthroughSubject<Int, Never>")
let passthroughSubject = PassthroughSubject<Int, Never>.init()

print(note: "Adding a subscriber")
passthroughSubject
	.sink(receiveCompletion: { print("Subs1 - Output: \($0)") }, receiveValue: { print("Subs1 - Event: \($0)") })
	.store(in: &cancellables)

print(note: "Passing down value 1")
passthroughSubject.send(1)

print(note: "Adding a second subscriber")
passthroughSubject
	.sink(receiveCompletion: { print("Subs2 - Output: \($0)") }, receiveValue: { print("Subs2 - Event: \($0)") })
	.store(in: &cancellables)

print(note: "Passing down value 2")
passthroughSubject.send(2)

print(note: "Passing down completion event `.finished`")
passthroughSubject.send(completion: .finished)

print(note: "Passing down value 3")
passthroughSubject.send(3)
