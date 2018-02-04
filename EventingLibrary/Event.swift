import Foundation

public final class Event<T>: Disposable {
    private var subscribers: [(T) -> ()] = []
    
    public init() {
        
    }
    
    public func subscribe(on handler: @escaping (T) -> ()) -> Disposable {
        subscribers.append(handler)
        return self // TODO: I might need a SubscriptionDisposable that contains a weak reference to self
    }
    
    public func on(_ value: T) {
        subscribers.forEach { $0(value) }
    }
        
    public func dispose() {
        subscribers.removeAll()
    }
}
