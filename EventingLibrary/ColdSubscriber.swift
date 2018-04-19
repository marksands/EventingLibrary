final class ColdSubscriber<T>: SubscriberBase<T> {
    init(handler: @escaping (T) -> (), currentValue: T?) {
        super.init(handler: handler)
        if let value = currentValue {
            handler(value)
        }
    }
    
    override func on(_ value: T) {
        guard !isDisposed else { return }
        handler(value)
    }
}
