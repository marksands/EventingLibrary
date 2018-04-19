import XCTest
import EventingLibrary

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
    
    func test_distinctSubscriberNotifiesSequentiallyDistinctEvents() {
        let event = Event<Int>()
        
        var observedCount = 0
        
        event.subscribeDistinct { _ in
            observedCount += 1
        }
        
        XCTAssertEqual(0, observedCount)

        event.on(1)
        event.on(1)
        event.on(1)
        event.on(1)
        
        XCTAssertEqual(1, observedCount)
        
        event.on(2)
        event.on(1)
        event.on(2)
        
        XCTAssertEqual(4, observedCount)
    }
    
    func test_distinctSubscriberCanCustomizeDistinctDefinition() {
        let event = Event<Int>()
        
        var observedCount = 0
        
        event.subscribeDistinct(on: { _ in
            observedCount += 1
        }, distinctHandler: { a, b -> Bool in
            return (a % 2) == 0 && (b % 2) == 0
        })
        
        event.on(2)
        XCTAssertEqual(1, observedCount)
        event.on(2)
        XCTAssertEqual(1, observedCount)
        event.on(3)
        XCTAssertEqual(2, observedCount)
        event.on(5)
        XCTAssertEqual(3, observedCount)
        event.on(6)
        XCTAssertEqual(4, observedCount)
        event.on(8)
        XCTAssertEqual(4, observedCount)
        event.on(1)
        XCTAssertEqual(5, observedCount)
    }
    
    func test_subscribersCanReceivePreviouslySentValue() {
        let event = Event<Int>()
        
        event.on(3)
        event.on(2)
        event.on(1)
        
        var observedValue = 0
        
        event.subscribeWithCurrentValue(on: {
            observedValue = $0
        })
        
        XCTAssertEqual(1, observedValue)
        
        event.on(2)
        XCTAssertEqual(2, observedValue)
    }
}
