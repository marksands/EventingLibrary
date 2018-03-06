import Foundation

public final class Event<T>: Disposable {
    private var subscribers: [SubscriberBase<T>] = []
    
    public init() {
        
    }
    
    @discardableResult
    public func subscribe(on handler: @escaping (T) -> ()) -> Disposable {
        let subscriber = IndefiniteSubscriber(handler: handler)
        subscribers.append(subscriber)
        return subscriber
    }
    
    @discardableResult
    public func single(_ handler: @escaping (T) -> ()) -> Disposable {
        let subscriber = SingleSubscriber(handler: handler)
        subscribers.append(subscriber)
        return subscriber
    }
    
    @discardableResult
    public func subscribeDistinct(on handler: @escaping (T) -> (), distinctHandler: @escaping (T, T) -> (Bool)) -> Disposable {
        let subscriber = DistinctSubscriber(handler: handler, distinctHandler: distinctHandler)
        subscribers.append(subscriber)
        return subscriber
    }

    public func on(_ value: T) {
        subscribers.forEach { $0.on(value) }
        cleanupDisposed()
    }
        
    public func dispose() {
        subscribers.removeAll()
    }
    
    private func cleanupDisposed() {
        subscribers = subscribers.filter { !$0.isDisposed }
    }
}

extension Event where T: Equatable {
    @discardableResult
    public func subscribeDistinct(on handler: @escaping (T) -> ()) -> Disposable {
        let subscriber = DistinctSubscriber(handler: handler, distinctHandler: ==)
        subscribers.append(subscriber)
        return subscriber
    }
}
