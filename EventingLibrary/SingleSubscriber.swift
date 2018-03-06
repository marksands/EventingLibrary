final class SingleSubscriber<T>: SubscriberBase<T> {
    override func on(_ value: T) {
        guard !isDisposed else { return }
        defer { dispose() }
        handler(value)
    }
}
