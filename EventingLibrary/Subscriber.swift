class Subscriber<T> {
    var handler: (T) -> ()
    
    init(handler: @escaping (T) -> ()) {
        self.handler = handler
    }
}

class IndefiniteSubscriber<T>: Subscriber<T> {
    
}

class SingleSubscriber<T>: Subscriber<T> {
    
}
