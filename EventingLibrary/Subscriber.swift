protocol Subscriber {
    associatedtype Value
    
    var handler: (Value) -> () { get }
}

extension Subscriber {
    func asSubscriber() -> AnySubscriber<Value> {
        return AnySubscriber(self)
    }
}

struct IndefiniteSubscriber<T>: Subscriber {
    typealias Value = T
    let handler: (T) -> ()
}

struct SingleSubscriber<T>: Subscriber {
    typealias Value = T
    let handler: (T) -> ()
}

struct AnySubscriber<T> {
    let handler: (T) -> ()
    let base: Any
    
    init<S: Subscriber>(_ subscriber: S) where S.Value == T {
        self.handler = subscriber.handler
        self.base = subscriber
    }
}
