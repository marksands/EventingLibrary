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
        
        let event = Notifier<[String:Int]>(notificationName)
        
        var actualValue: [String:Int] = [:]
        
        disposeBag += event.subscribe(on: { value in
            actualValue = value
        })
        
        XCTAssertEqual([:], actualValue)
        
        event.on(["Key":3])
        XCTAssertEqual(["Key":3], actualValue)
        
        event.on(["AnotherKey":7])
        XCTAssertEqual(["AnotherKey":7], actualValue)
    }
    
    func test_notifierPostsAsNotificationCenter() {
        let notificationName = Notification.Name("TestNotifier2")
        
        let event = Notifier<TestEnum>(notificationName)
        
        var actualValue = TestEnum.waiting
        
        disposeBag += event.subscribe(on: { _ in })
        
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: { notification in
            if let object = notification.object, let data = object as? TestEnum {
                actualValue = data
            }
        })
        
        XCTAssertEqual(TestEnum.waiting, actualValue)
        
        event.on(TestEnum.success1)
        XCTAssertEqual(TestEnum.success1, actualValue)
        
        event.on(TestEnum.success2)
        XCTAssertEqual(TestEnum.success2, actualValue)
    }
}
