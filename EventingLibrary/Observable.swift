public class Observable<T> {
    internal var subscribers: [SubscriberBase<T>] = []
    internal var _value: T?
    
    public var value: T? {
        return _value
    }
    
    public init() { }

    deinit {
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
    
    @discardableResult
    public func subscribeWithCurrentValue(on handler: @escaping (T) -> ()) -> Disposable {
        let subscriber = ColdSubscriber(handler: handler, currentValue: _value)
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
