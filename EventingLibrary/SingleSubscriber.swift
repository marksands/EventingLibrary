final class SingleSubscriber<T>: SubscriberBase<T> {
    init(handler: @escaping (T) -> (), currentValue: T?) {
        super.init(handler: handler)
        if let value = currentValue {
            handler(value)
            dispose()
        }
    }

    override func on(_ value: T) {
        guard !isDisposed else { return }
        defer { dispose() }
        handler(value)
    }
}
