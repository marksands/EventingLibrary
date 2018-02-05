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
}
