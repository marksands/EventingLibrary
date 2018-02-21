import XCTest
import EventingLibrary

class TestClass {
    var value: Int
    
    init(value: Int) {
        self.value = value
    }
}

class EventingLibraryTests: XCTestCase {
    let disposeBag = DisposeBag()

    func test_eventSubscribesToStreamsOfValues() {
        let event = Event<Int>()
        
        var actualValue: Int?
        
        disposeBag += event.subscribe { value in
            actualValue = value
        }
        
        XCTAssertNil(actualValue)
        
        event.on(42)
        XCTAssertEqual(42, actualValue)

        event.on(3)
        XCTAssertEqual(3, actualValue)
    }
    
    func test_singleEventSubscribesToOneAndOnlyOneEvent() {
        let event = Event<Int>()
        
        var actualValue: Int?
        
        disposeBag += event.single { value in
            actualValue = value
        }
        
        event.on(42)
        XCTAssertEqual(42, actualValue)
        
        event.on(3)
        XCTAssertEqual(42, actualValue)
    }
    
    func test_subscribeAndSingleDoNotRequireDisposable() {
        let event = Event<String>()
        
        var observedCount = 0

        event.subscribe { _ in
            observedCount += 1
        }

        event.single { _ in
            observedCount += 1
        }
        
        event.on("SingleAndSubscribe")
        XCTAssertEqual(2, observedCount)

        event.on("SingleIsDisposedImplicitly")
        XCTAssertEqual(3, observedCount)
    }
}
