import Foundation

public class Observable<T> {
    fileprivate var subscribers: [SubscriberBase<T>] = []
    
    public init() {}
    
    deinit {
        dispose()
    }
    
    public func dispose() {
        subscribers.removeAll()
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
}

extension Observable where T: Equatable {
    @discardableResult
    public func subscribeDistinct(on handler: @escaping (T) -> ()) -> Disposable {
        let subscriber = DistinctSubscriber(handler: handler, distinctHandler: ==)
        subscribers.append(subscriber)
        return subscriber
    }
}

public final class Event<T>:  Observable<T>, Disposable  {
    override public init() {}
    
    public func on(_ value: T) {
        subscribers.forEach { $0.on(value) }
        cleanupDisposed()
    }
    
    private func cleanupDisposed() {
        subscribers = subscribers.filter { !$0.isDisposed }
    }
}
