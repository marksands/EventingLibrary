extension Observable {
    public static func combine<A, B>(_ a: Observable<A>, _ b: Observable<B>) -> Observable<(A, B)> {
        let event = Event<(A, B)>()
        a.subscribe { if let _b = b._value { event.on(($0, _b)) } }
        b.subscribe { if let _a = a._value { event.on((_a, $0)) } }
        return event
    }
    
    public static func combine<A, B, C>(_ a: Observable<A>, _ b: Observable<B>, _ c: Observable<C>) -> Observable<(A, B, C)> {
        let event = Event<(A, B, C)>()
        a.subscribe { if let _b = b._value, let _c = c._value { event.on(($0, _b, _c)) } }
        b.subscribe { if let _a = a._value, let _c = c._value { event.on((_a, $0, _c)) } }
        c.subscribe { if let _a = a._value, let _b = b._value { event.on((_a, _b, $0)) } }
        return event
    }
    
    public static func combine<A, B, C, D>(_ a: Observable<A>, _ b: Observable<B>, _ c: Observable<C>, _ d: Observable<D>) -> Observable<(A, B, C, D)> {
        let event = Event<(A, B, C, D)>()
        a.subscribe { if let _b = b._value, let _c = c._value, let _d = d._value { event.on(($0, _b, _c, _d)) } }
        b.subscribe { if let _a = a._value, let _c = c._value, let _d = d._value { event.on((_a, $0, _c, _d)) } }
        c.subscribe { if let _a = a._value, let _b = b._value, let _d = d._value { event.on((_a, _b, $0, _d)) } }
        d.subscribe { if let _a = a._value, let _b = b._value, let _c = c._value { event.on((_a, _b, _c, $0)) } }
        return event
    }
}
