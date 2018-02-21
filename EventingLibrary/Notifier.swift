import Foundation

private final class NotificationDisposable: Disposable {
    private let notificationObserver: NSObjectProtocol
    
    init(name: Notification.Name, handler: @escaping ([AnyHashable: Any]) -> ()) {
        notificationObserver = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: { notification in
            let userInfo = notification.userInfo ?? [:]
            handler(userInfo)
        })
    }
    
    init(name: Notification.Name, target: Any?, handler: @escaping (Notification) -> ()) {
        notificationObserver = NotificationCenter.default.addObserver(forName: name, object: target, queue: nil, using: { notification in
            handler(notification)
        })
    }
    
    deinit {
        dispose()
    }
    
    public func dispose() {
        NotificationCenter.default.removeObserver(notificationObserver)
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
    
    public func subscribe(target: Any?, on handler: @escaping (Notification) -> ()) -> Disposable {
        return NotificationDisposable(name: name, target: target, handler: handler)
    }
    
    public func on(_ value: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: name, object: nil, userInfo: value)
    }
}
