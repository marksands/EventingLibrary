import Foundation

public final class NotificationDisposable<T>: Disposable {
    private var handler: (T) -> ()
    private var notificationObserver: NSObjectProtocol?
    
    internal init(name: Notification.Name, handler: @escaping (T) -> ()) {
        self.handler = handler
        
        notificationObserver = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: { [weak self] notification in
            if let object = notification.object, let value = object as? T {
                self?.handler(value)
            }
        })
    }
    
    deinit {
        dispose()
    }
    
    public func dispose() {
        notificationObserver.map(NotificationCenter.default.removeObserver)
    }
}

public struct Notifier<T> {
    private let name: Notification.Name
    
    public init(_ name: String) {
        self.name = Notification.Name(rawValue: name)
    }
    
    public init(_ name: Notification.Name) {
        self.name = name
    }
    
    public func subscribe(on handler: @escaping (T) -> ()) -> Disposable {
        return NotificationDisposable(name: name, handler: handler)
    }
    
    public func on(_ value: T) {
        NotificationCenter.default.post(name: name, object: value)
    }
}
