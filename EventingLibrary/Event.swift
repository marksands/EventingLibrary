import Foundation

public final class Event<T>: Disposable {
    private var subscribers: [AnySubscriber<T>] = []
    
    public init() {
        
    }
    
    @discardableResult
    public func subscribe(on handler: @escaping (T) -> ()) -> Disposable {
        let subscriber = IndefiniteSubscriber(handler: handler)
        subscribers.append(subscriber.asSubscriber())
        return self
    }
    
    @discardableResult
    public func single(_ handler: @escaping (T) -> ()) -> Disposable {
        let subscriber = SingleSubscriber(handler: handler)
        subscribers.append(subscriber.asSubscriber())
        return self
    }
    
    public func on(_ value: T) {
        subscribers.forEach { $0.handler(value) }
        purgeSingleSubscribers()
    }
        
    public func dispose() {
        subscribers.removeAll()
    }
    
    private func purgeSingleSubscribers() {
        subscribers = subscribers.filter { ($0.base as? SingleSubscriber<T>) == nil }
    }
}
