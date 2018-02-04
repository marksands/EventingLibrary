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
        
        disposeBag += event.subscribe(on: { value in
            actualValue = value
        })
        
        XCTAssertNil(actualValue)
        
        event.on(42)
        XCTAssertEqual(42, actualValue)

        event.on(3)
        XCTAssertEqual(3, actualValue)
    }
}
