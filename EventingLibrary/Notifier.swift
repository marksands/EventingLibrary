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

public class Notifier {
    private let name: Notification.Name
    private var subscribers: [NotificationDisposable] = []
    
    public init(_ name: String) {
        self.name = Notification.Name(rawValue: name)
    }
    
    public init(_ name: Notification.Name) {
        self.name = name
    }
    
    @discardableResult
    public func subscribe(on handler: @escaping ([AnyHashable: Any]) -> ()) -> Disposable {
        let disposabale = NotificationDisposable(name: name, handler: handler)
        subscribers.append(disposabale)
        return disposabale
    }
    
    @discardableResult
    public func subscribe(target: Any?, on handler: @escaping (Notification) -> ()) -> Disposable {
        let disposable = NotificationDisposable(name: name, target: target, handler: handler)
        subscribers.append(disposable)
        return disposable
    }
    
    public func on(_ value: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: name, object: nil, userInfo: value)
    }
}
