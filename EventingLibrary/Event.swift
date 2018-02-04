import Foundation

public final class Event<T>: Disposable {
    private var subscribers: [Subscriber<T>] = []

    public init() {
        
    }
    
    public func subscribe(on handler: @escaping (T) -> ()) -> Disposable {
        let subscriber = IndefiniteSubscriber(handler: handler)
        subscribers.append(subscriber)
        return self // TODO: I might need a SubscriptionDisposable that contains a weak reference to self
    }
    
    public func single(_ handler: @escaping (T) -> ()) -> Disposable {
        let subscriber = SingleSubscriber(handler: handler)
        subscribers.append(subscriber)
        return self
    }
    
    public func on(_ value: T) {
        subscribers.forEach { $0.handler(value) }
        subscribers = subscribers.filter { ($0 as? SingleSubscriber) == nil }
    }
        
    public func dispose() {
        subscribers.removeAll()
    }
}
