public class Event<T>: Observable<T> {
    public func on(_ value: T) {
        subscribers.forEach { $0.on(value) }
        _value = value
        cleanupDisposed()
    }
    
    private func cleanupDisposed() {
        subscribers = subscribers.filter { !$0.isDisposed }
    }
}
