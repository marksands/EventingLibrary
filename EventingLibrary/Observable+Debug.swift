import Foundation.NSString

extension Observable {
    public func debug(_ identifier: String? = nil, file: String = #file, line: UInt = #line, function: String = #function) -> Observable<T> {
        let subscriber = DebugSubscriber<T>(identifier: identifier, file: file, line: line, function: function)
        subscribers.append(subscriber)
        return self
    }
}

private final class DebugSubscriber<T>: SubscriberBase<T> {
    private let identifier: String
    private let dateFormatter = DateFormatter()

    fileprivate init(identifier: String?, file: String, line: UInt, function: String) {
        if let identifier = identifier {
            self.identifier = identifier
        } else {
            let filePath = (file as NSString).lastPathComponent
            self.identifier = "\(filePath):\(line) (\(function))"
        }
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        super.init(handler: { _ in })
        
        logEvent(content: "Subscribed")
    }
    
    override fileprivate func on(_ value: T) {
        logEvent(content: "Value (\(value))")
    }
    
    override fileprivate func dispose() {
        if !isDisposed {
            logEvent(content: "isDisposed")
        }
        super.dispose()
    }
    
    private func logEvent(content: String) {
        print("\(dateFormatter.string(from: Date())): \(identifier) -> \(content)")
    }
}
