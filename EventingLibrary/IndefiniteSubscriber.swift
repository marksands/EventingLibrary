final class IndefiniteSubscriber<T>: SubscriberBase<T> {
    override func on(_ value: T) {
        guard !isDisposed else { return }
        handler(value)
    }
}
