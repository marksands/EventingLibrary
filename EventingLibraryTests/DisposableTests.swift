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
}
