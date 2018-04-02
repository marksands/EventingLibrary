extension Observable {
    public static func merge(_ values: Observable<T>...) -> Observable<T> {
        let all = Array(values)
        let event = Event<T>()
        
        all.forEach { o in
            o.subscribe(on: {
                event.on($0)
            })
        }

        return event
    }
}
