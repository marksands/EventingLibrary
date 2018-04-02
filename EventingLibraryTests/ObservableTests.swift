import XCTest
import EventingLibrary

class ObservableTests: XCTestCase {
    let disposeBag = DisposeBag()
    
    func test_observableIsInterfaceForEvents() {
        let event = Event<Int>()
        let observable: Observable<Int> = event
        
        var actualValue: Int?
        
        disposeBag += observable.subscribe { value in
            actualValue = value
        }
        
        XCTAssertNil(actualValue)
        
        event.on(42)
        XCTAssertEqual(42, actualValue)
        
        event.on(3)
        XCTAssertEqual(3, actualValue)
    }
    
    func test_observableMap() {
        let event = Event<Int>()
        
        var actualValue: String?
        
        event.map { String($0) }.subscribe(on: { stringValue in
            actualValue = stringValue
        })
        
        XCTAssertNil(actualValue)
        
        event.on(42)
        XCTAssertEqual("42", actualValue)
        
        event.on(3)
        XCTAssertEqual("3", actualValue)
    }
    
    func test_observableMerge() {
        let event1 = Event<Int>()
        let event2 = Event<Int>()
        let event3 = Event<Int>()

        var actualValue: Int?
        
        let event = Observable.merge(event1, event2, event3)
        
        disposeBag += event.subscribe {
            actualValue = $0
        }
        
        XCTAssertNil(actualValue)
        
        event1.on(42)
        XCTAssertEqual(42, actualValue)
        
        event2.on(3)
        XCTAssertEqual(3, actualValue)

        event3.on(7)
        XCTAssertEqual(7, actualValue)
    }
    
    func test_observableCombine2() {
        let event1 = Event<Int>()
        let event2 = Event<Int>()
        
        let event = Observable<(Int, Int)>.combine(event1, event2)
        
        var actualValue: String?

        event.subscribe { a, b in
            actualValue = "\(a),\(b)"
        }
        
        XCTAssertNil(actualValue)
        
        event1.on(41)
        XCTAssertNil(actualValue)

        event1.on(42)
        event2.on(3)
        XCTAssertEqual("42,3", actualValue)

        event1.on(7)
        XCTAssertEqual("7,3", actualValue)
    }

    func test_observableCombine3() {
        let event1 = Event<Int>()
        let event2 = Event<Int>()
        let event3 = Event<Int>()

        let event = Observable<String>
            .combine(event1, event2, event3)
            .map { String($0 + $1 + $2) }
        
        var actualValue: String?
        
        event.subscribe { value in
            actualValue = value
        }
        
        XCTAssertNil(actualValue)
        
        event1.on(1)
        event2.on(1)
        XCTAssertNil(actualValue)
        event3.on(1)
        XCTAssertEqual("3", actualValue)
        
        event1.on(5)
        XCTAssertEqual("7", actualValue)
        event2.on(5)
        XCTAssertEqual("11", actualValue)
        event3.on(5)
        XCTAssertEqual("15", actualValue)
    }

    func test_observableCombine4() {
        let event1 = Event<String>()
        let event2 = Event<String>()
        let event3 = Event<String>()
        let event4 = Event<String>()
        let event = Observable<String>.combine(event1, event2, event3, event4).map { $0 + $1 + $2 + $3 }
        
        var actualValue: String?
        
        event.subscribe { value in
            actualValue = value
        }
        
        XCTAssertNil(actualValue)
        
        event1.on("A")
        event2.on("B")
        event3.on("C")
        XCTAssertNil(actualValue)
        
        event4.on("D")
        XCTAssertEqual("ABCD", actualValue)
        event1.on("_A")
        XCTAssertEqual("_ABCD", actualValue)
        event2.on("B_")
        XCTAssertEqual("_AB_CD", actualValue)
        event4.on("D_")
        XCTAssertEqual("_AB_CD_", actualValue)
    }
    
    func test_observableFilter() {
        let event = Event<Int>()
        
        var actualValue: Int?
        
        event
            .filter { $0 > 5 }
            .subscribe {
                actualValue = $0
        }
        
        XCTAssertNil(actualValue)
        
        event.on(1)
        event.on(2)
        event.on(3)
        event.on(4)
        event.on(5)
        XCTAssertNil(actualValue)
        
        event.on(6)
        XCTAssertEqual(6, actualValue)
        
        event.on(4)
        XCTAssertEqual(6, actualValue)

        event.on(7)
        XCTAssertEqual(7, actualValue)
    }
}
