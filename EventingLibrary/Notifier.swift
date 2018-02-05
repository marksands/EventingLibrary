import Foundation

public final class NotificationDisposable: Disposable {
    private var handler: ([AnyHashable: Any]) -> ()
    private var notificationObserver: NSObjectProtocol?
    
    internal init(name: Notification.Name, handler: @escaping ([AnyHashable: Any]) -> ()) {
        self.handler = handler
        
        notificationObserver = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: { [weak self] notification in
            if let userInfo = notification.userInfo {
                self?.handler(userInfo)
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

public struct Notifier {
    private let name: Notification.Name
    
    public init(_ name: String) {
        self.name = Notification.Name(rawValue: name)
    }
    
    public init(_ name: Notification.Name) {
        self.name = name
    }
    
    public func subscribe(on handler: @escaping ([AnyHashable: Any]) -> ()) -> Disposable {
        return NotificationDisposable(name: name, handler: handler)
    }
    
    public func on(_ value: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: name, object: nil, userInfo: value)
    }
}
