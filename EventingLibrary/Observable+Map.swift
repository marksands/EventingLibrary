extension Observable {
    public func map<U>(_ fn: @escaping (T) -> U) -> Observable<U> {
        let event = Event<U>()
        subscribe { value in
            event.on(fn(value))
        }
        return event
    }
}
