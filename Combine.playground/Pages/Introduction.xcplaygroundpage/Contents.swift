/*:

# Combine Framework Playground
* Author: [Andrés Emilio Pesate Temprano](https://www.linkedin.com/in/andrespesate/)

---
* Callout(References):
	- [Using Combine - Joseph Heck](https://heckj.github.io/swiftui-notes/)
	- [Apple's Combine Documentation](https://developer.apple.com/documentation/combine)
	- [WWDC 2019](https://developer.apple.com/videos/play/wwdc2019?q=Combine)

- Callout(Relevant Concepts):
	**Stream**: sequence of data elements made available over time.

	**Reactive Programming**: declarative programming paradigm concerned with data streams and the propagation of change.

	**Functional Programming**: programming paradigm where programs are constructed by applying and composing functions. It' s a declarative programming paradigm in which function definitions are trees of expressions that each return a value, rather than a sequence of imperative statements which change the state of the program.

	**Functional Reactive Programming**: programming paradigm for reactive programming using the building blocks of functional programming.

	**Combine**:  declarative Swift API for processing values over time.

## Core Concepts
- **[Publisher](Publishers)**: protocol that defines that an object can deliver values over time.
- **[Subscriber](Subscribers)**: protocol that defines that an object can listen to the events emitted by a publisher.
- **[Subjects](Subjects)**: special type of publisher that allows the injection of values into its stream.
- **[Operators](Operators)**: term giving to the methods that can be applied to the data streams of a publisher.

## Life cycle
![Publisher-Subscriber](Publisher-Subscriber.png)
*Illustration taken from [Ray Wenderlich](https://www.raywenderlich.com/7864801-combine-getting-started#toc-anchor-004)*
1. A `Subscriber` is attached to a `Publisher` by calling `.subscribe(_: Subscriber)` on it.
2. The `Publisher` acknowledges the subscription by calling `receive(subscription: Subscription)` on its counterpart.
3. At this point, the `Publisher` is ready to start emitting output events as demanded by its `Subscriber` when calling `request(_: Demand)`.
4. The `Publisher` may then (as it has values) send N (or fewer) values using `receive(_: Input)`. A `Publisher` should never send more than the demand requested.
5. A `Publisher` may optionally send a completion event. `receive(completion:)`. A completion can be either a normal termination, or may be a `.failure` completion, optionally propagating an error type. A pipeline that has been cancelled will not send any completions.
*/
import Combine
/*:
---
* Callout(Life Cycle):
Demostrate the life cycle of a Publisher-Subscriber
*/
print(beginningOf: "Life Cycle")
Just(5)
	.print()
	.sink(receiveValue: print(result:))
printEndOfSection()
