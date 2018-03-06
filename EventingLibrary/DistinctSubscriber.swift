final class DistinctSubscriber<T>: SubscriberBase<T> {
    private let distinctHandler: (T, T) -> (Bool)
    private var previousValue: T?
    
    init(handler: @escaping (T) -> (), distinctHandler: @escaping (T, T) -> (Bool)) {
        self.distinctHandler = distinctHandler
        super.init(handler: handler)
    }
    
    override func on(_ value: T) {
        guard !isDisposed else { return }
        
        guard let previousValue = previousValue else {
            callHandler(value)
            return
        }
        
        if !distinctHandler(previousValue, value) {
            callHandler(value)
        }
    }
    
    private func callHandler(_ value: T) {
        previousValue = value
        handler(value)
    }
}
