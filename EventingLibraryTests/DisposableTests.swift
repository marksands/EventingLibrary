import XCTest
import EventingLibrary

class DisposableTests: XCTestCase {
    func test_disposableDisposes() {
        let event = Event<Int>()
        var disposable: Disposable?
        
        var actualValue: Int?
        
        disposable = event.subscribe(on: { value in
            actualValue = value
        })
        
        XCTAssertNotNil(disposable)
        
        disposable?.dispose()
        
        event.on(42)
        XCTAssertNil(actualValue)
    }
    
    func test_disposeBagDisposes() {
        let event = Event<Int>()
        let disposeBag = DisposeBag()
        
        var actualValue: Int?
        
        disposeBag.addDisposable(event.subscribe(on: { value in
            actualValue = value
        }))
        
        event.on(42)
        XCTAssertEqual(42, actualValue)

        disposeBag.dispose()
        
        event.on(43)
        XCTAssertEqual(42, actualValue)
    }
    
    func test_disposeBagContainsDisposables() {
        let disposeBag = DisposeBag()
        
        let event1 = Event<Int>()
        let event2 = Event<String>()
        
        var actualIntValue: Int?
        var actualStringValue: String?
        
        disposeBag += event1.subscribe(on: { value in
            actualIntValue = value
        })
        
        disposeBag += event2.subscribe(on: { value in
            actualStringValue = value
        })

        event1.on(42)
        event2.on("42")
        
        disposeBag.dispose()

        event1.on(3)
        event2.on("3")

        XCTAssertEqual(42, actualIntValue)
        XCTAssertEqual("42", actualStringValue)
    }
    
    func test_disposeCancellsOnlyReferencedSubscriptions() {
        let event = Event<Int>()
        let disposeBag = DisposeBag()

        var observedValue1: Int?
        var observedValue2: Int?
        var observedValue3: Int?

        disposeBag += event.subscribe(on: { value in
            observedValue1 = value
        })
        
        disposeBag += event.subscribe(on: { value in
            observedValue2 = value
        })

        event.subscribe(on: { value in
            observedValue3 = value
        })

        event.on(2)
        XCTAssertEqual(2, observedValue1)
        XCTAssertEqual(2, observedValue2)
        XCTAssertEqual(2, observedValue3)

        disposeBag.dispose()

        event.on(3)
        XCTAssertEqual(2, observedValue1)
        XCTAssertEqual(2, observedValue2)
        XCTAssertEqual(3, observedValue3)
    }
    
    func test_disposesOnDeinit() {
        let event = Event<Int>()
        var disposeBag = DisposeBag()
        
        var observedValue: Int?
        
        disposeBag += event.subscribe(on: { value in
            observedValue = value
        })
        
        event.on(1)
        XCTAssertEqual(1, observedValue)

        disposeBag = DisposeBag()
        
        event.on(2)
        XCTAssertEqual(1, observedValue)
    }
    
    func test_disposablesDontRetainEventsLongerThanNecessary() {
        weak var weakEvent: Event<Int>?
        var disposable: Disposable?

        var actualValue = 0

        autoreleasepool {
            let event = Event<Int>()
            disposable = event.subscribe { value in
                actualValue = value
            }
            
            weakEvent = event
        }
        
        XCTAssertTrue(disposable?.isDisposed ?? false)

        weakEvent?.on(42)
        XCTAssertEqual(0, actualValue)
    }
    
    func test_disposableActionCalledOnDispose() {
        // TODO
    }
    
    func test_observableCreateDisposesWithDisposeAction() {
        // TODO
    }
}
