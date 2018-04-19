#  EventingLibrary

### _Rx training wheels 🚲_

![platforms](https://img.shields.io/badge/platforms-iOS-333333.svg) ![License](https://img.shields.io/badge/license-MIT-blue.svg)

EventingLibrary is a lightweight observable framework that makes it simple for the developer. The interface closely resembles RxSwift on purpose. If you find that you need more power, then the upgrade path to Rx should be fairly straightforward.

## Observable

`Observable`s subscribe to streams of values.

```swift
import EventingLibrary

// expose Observables in your public interface
public protocol Tappable {
	var tapped: Observable<Void> { get }
}
```

## Event

`Event`s can subscribe to other `Event`s and `Observable`s as well as send values. Because `Event`s are `Observable`s, they can both send and recive values.

```swift
import EventingLibrary

let event = Event<Int>()
let disposeBag = DisposeBag()

// subscriptions create a stream of values over time
disposeBag += event.subscribe(on: { value in
    print("Got \(value)!")
})

// Send an event to all subscribers
event.on(3)

// Subscribe to streams with the side effect of consuming the previously sent value
disposeBag += event.subscribeWithCurrentValue { value in
    // value is 3 on subscription
}

// optionally dispose the stream
disposeBag.dispose()
```

## Notifier

`Notifier` provides type safety for `NotificationCenter` and allows you to emit custom Swift objects through Notification's userInfo.

```swift
import EventingLibrary

let event = Notifier(Notification.Name("ViewStateChanged"))

// equivalent to NotificationCenter.default.post(name: name, object: ViewState.loading)
event.on(["key": ViewState.loading])

// Or subscribe to notifications and handle them with a closure
disposeBag += event.subscribe(on: { userInfo in
    guard let state = userInfo["key"] as? ViewState else { return }
    print("Got view state: \(state)!")
})
```

## Disposable

Disposables are _optional_ for `Event`s but _required_ for `Notifier`s. If your subscription is retained by a disposable, you may `dispose()` of the subscription to stop receiving events to that handler.

## Observable Operators

### Filter

Filter values sent by an Event by applying a predicate to each value.

```swift
import EventingLibrary

let event = Event<Int>()

// Creates an event that filters odd numbers
let onlyEvenNumbers: Event<Int> = event.filter { $0 % 2 == 0 }
```

### Map

Transform the values sent by an Event by applying a function to each value.

```swift
import EventingLibrary

let event = Event<Int>()

// Map Int values to Strings from the event
let intToStringEvent: Event<String> = event.map { String($0) }
```

### Merge

Combine multiple events into a single event by merging their emitted values.

```swift
import EventingLibrary

let event1 = Event<Int>()
let event2 = Event<Int>()

let mergedIntsEvent: Event<Int> = Observable.merge(event1, event2)
```

### Combine

Combine the latest value from multiple events and emit their results as a single unit.

```swift
import EventingLibrary

let event1 = Event<Int>()
let event2 = Event<String>()

let combinedEvents: Event<(Int, String)> = Observable.combine(event1, event2)
```

Chain mutlipe operators to create powerful transformations.

```swift
struct AuthenticationCredentials {
    let email: String
    let password: String
}

let validAuthCredentials = Observable<AuthenticationCredentials>
    .combine(
        emailEvent.filter(isValidEmail),
        passwordEvent.filter(isValidPassword)
    ).map(AuthenticationCredentials.init)

validAuthCredentials.subscribe {
    service.authenticate($0)
}
```

## FAQ

Should I use this?

* Probably not. 🤷🏼‍♀️

