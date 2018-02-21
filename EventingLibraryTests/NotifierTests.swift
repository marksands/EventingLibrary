import XCTest
import EventingLibrary

enum TestEnum: Equatable {
    case waiting
    case success1
    case success2
    
    static func == (lhs: TestEnum, rhs: TestEnum) -> Bool {
        switch (lhs, rhs) {
        case (.waiting, .waiting): return true
        case (.success1, .success1): return true
        case (.success2, .success2): return true
        default: return false
        }
    }
}

class NotifierTests: XCTestCase {
    let disposeBag = DisposeBag()
    
    func test_notifierSubscribesToStreamsOfValues() {
        let notificationName = Notification.Name("TestNotifier")
        
        let event = Notifier(notificationName)
        
        var actualValue: Int?
        
        disposeBag += event.subscribe(on: { value in
            actualValue = value["Key"] as? Int
        })
        
        XCTAssertNil(actualValue)
        
        event.on(["Key":3])
        XCTAssertEqual(3, actualValue)
        
        event.on(["Key":7])
        XCTAssertEqual(7, actualValue)
    }
    
    func test_notifierPostsAsNotificationCenter() {
        let notificationName = "TestNotifier2"
        
        let event = Notifier(notificationName)
        
        var actualValue = TestEnum.waiting
        
        disposeBag += event.subscribe(on: { _ in })
        
        NotificationCenter.default.addObserver(forName: Notification.Name(notificationName), object: nil, queue: nil, using: { notification in
            if let userInfo = notification.userInfo, let value = userInfo["Enum"] as? TestEnum {
                actualValue = value
            }
        })
        
        XCTAssertEqual(TestEnum.waiting, actualValue)
        
        event.on(["Enum": TestEnum.success1])
        XCTAssertEqual(TestEnum.success1, actualValue)
        
        event.on(["Enum": TestEnum.success2])
        XCTAssertEqual(TestEnum.success2, actualValue)
    }
    
    func test_notifierSubscribesToNotificationsWhenUserInfoIsNil() {
        let notificationName = Notification.Name("TestNotifier")
        let event = Notifier(notificationName)
        
        var observeCount = 0
        
        disposeBag += event.subscribe { _ in
            observeCount += 1
        }
        
        NotificationCenter.default.post(name: notificationName, object: nil)
        
        XCTAssertEqual(1, observeCount)
    }
    
    func test_notifierCanSubscribeToNotificationObject() {
        let notificationName = Notification.Name("TestNotifier")
        let event = Notifier(notificationName)
        
        var notification: Notification?
        
        disposeBag += event.subscribe(target: self) {
            notification = $0
        }
        
        NotificationCenter.default.post(name: notificationName, object: self)
        
        XCTAssertNotNil(notification)
        XCTAssertEqual(self, notification?.object as? NotifierTests)
    }
    
    func test_notifierRequiresDisposeBagToRetainObserver() {
        let notificationName = Notification.Name("TestNotifier")
        let event = Notifier(notificationName)
        
        var observeCount = 0
        var observeCountWithDisposable = 0

        autoreleasepool {
            _ = event.subscribe { value in
                observeCount += 1
            }

            disposeBag += event.subscribe { _ in
                observeCountWithDisposable += 1
            }
        }
        
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: [:])
        
        XCTAssertEqual(0, observeCount)
        XCTAssertEqual(1, observeCountWithDisposable)
    }
}
