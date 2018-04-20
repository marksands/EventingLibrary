extension Observable {
    public func map<U>(_ fn: @escaping (T) -> U) -> Observable<U> {
        let event = Event<U>()
        subscribeWithCurrentValue { value in
            event.on(fn(value))
        }
        return event
    }
    
    public func flatMap<U>(_ fn: @escaping (T) -> Observable<U>) -> Observable<U> {
        let event = Event<U>()
        subscribeWithCurrentValue { value in
            fn(value).singleWithCurrentValue { transformedValue in
                event.on(transformedValue)
            }
        }
        return event
    }
}
