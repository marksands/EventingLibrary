class SubscriberBase<T>: Disposable {
    var handler: (T) -> ()
    var isDisposed = false
    
    init(handler: @escaping (T) -> ()) {
        self.handler = handler
    }
    
    func on(_ value: T) {
        fatalError()
    }
    
    func dispose() {
        isDisposed = true
    }
}
