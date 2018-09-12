extension Observable {
    @discardableResult
    public func throttle(_ interval: TimeInterval) -> Observable<T> {
        let event = Event<T>()
        let throttler = ThrottleForwardSubscriber(interval: interval, handler: { value in
            event.on(value)
        })
        subscribers.append(throttler)
        return event
    }
} 

final class ThrottleForwardSubscriber<T>: SubscriberBase<T> {
    private let interval: TimeInterval
    private var lastEventDate: Date?
    
    init(interval: TimeInterval, handler: @escaping (T) -> ()) {
        self.interval = interval
        super.init(handler: handler)
    }
    
    override func on(_ value: T) {
        guard !isDisposed else { return }
        
        let intervalSinceLastEvent = lastEventDate.map {
            Date().timeIntervalSince($0)
        } ?? TimeInterval.greatestFiniteMagnitude
        
        guard intervalSinceLastEvent >= interval else {
            return
        }
        
        lastEventDate = Date()
        
        handler(value)
    }
}
