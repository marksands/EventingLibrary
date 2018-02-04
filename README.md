#  EventingLibrary

### _Rx training wheels 🚲_
---
![platforms](https://img.shields.io/badge/platforms-iOS-333333.svg) ![License](https://img.shields.io/badge/license-MIT-blue.svg)

## The Pitch

EventingLibrary is a lightweight observable framework that makes it simple for the developer. The interface closely resembles RxSwift on purpose. If you find that you need more power, then the upgrade path to Rx should be fairly straightforward.

## Event

```swift
import EventingLibrary

let event = Event<Int>()
let disposeBag = DisposeBag()

// subscriptions create a stream of values over time
disposeBag += event.subscribe(on: { value in
    print("Got \(value)!")
})

// optionally dispose the stream
disposeBag.dispose()
```

## Notifier

`Notifier<T>` provides type safety for `NotificationCenter` and allows you to emit custom Swift objects through Notifications.

```swift
import EventingLibrary

let event = Notifier<ViewState>(Notification.Name("ViewStateChanged"))

// equivalent to NotificationCenter.default.post(name: name, object: ViewState.loading)
event.on(ViewState.loading)

// Or subscribe to notifications and handle them with a closure
disposeBag += event.subscribe(on: { state in
    print("Got view state: \(state)!")
})
```
