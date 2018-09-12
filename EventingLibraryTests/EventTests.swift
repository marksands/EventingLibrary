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
    
    func test_subscribersCanReceivePreviouslySentValueAfterMapping() {
        let event = Event<Int>()
        
        event.on(3)
        event.on(2)
        event.on(1)
        
        var observedValue = "0"
        
        event.map(String.init).subscribeWithCurrentValue(on: {
            observedValue = $0
        })
        
        XCTAssertEqual("1", observedValue)
        
        event.on(2)
        XCTAssertEqual("2", observedValue)
    }
    
    func test_observablesCreatedWithStaticHelperCreatesSingleEvent() {
        let observable = Observable<Int>.create { event in
            event.on(3)
            return DisposableAction { }
        }

        var actualValue: Int?

        observable.subscribe {
            actualValue = $0
        }
        XCTAssertNil(actualValue)

        observable.subscribeWithCurrentValue {
            actualValue = $0
        }
        XCTAssertEqual(3, actualValue)
    }
    
    func test_observablesThrottle() {
        let observable = Event<Int>()

        var throttledValue: Int?
        let disposable = observable.throttle(0.3).subscribe {
            throttledValue = $0
        }

        var actualValue: Int?
        observable.subscribe {
            actualValue = $0
        }

        observable.on(1)
        observable.on(2)
        observable.on(3)
        observable.on(4)
        observable.on(5)
        XCTAssertEqual(1, throttledValue)
        XCTAssertEqual(5, actualValue)

        RunLoop.current.run(until: Date().addingTimeInterval(0.5))

        observable.on(8)
        observable.on(9)
        observable.on(10)
        XCTAssertEqual(8, throttledValue)
        XCTAssertEqual(10, actualValue)
        
        disposable.dispose()
        
        RunLoop.current.run(until: Date().addingTimeInterval(0.3))

        observable.on(11)
        XCTAssertEqual(8, throttledValue)
        XCTAssertEqual(11, actualValue)
    }
}
