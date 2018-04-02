extension Observable {
    public func filter(_ predicate: @escaping (T) -> Bool) -> Observable<T> {
        let event = Event<T>()
        subscribe(on: { value in
            if predicate(value) {
                event.on(value)
            }
        })
        return event
    }
}
