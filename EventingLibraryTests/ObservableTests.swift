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
    
    func test_observableMap_withCurrentValue() {
        let event = Event<Int>()
        
        var actualValue: String?
        
        event.on(1)

        event
            .map { String($0) }
            .subscribeWithCurrentValue {
                actualValue = $0
        }
        
        XCTAssertEqual("1", actualValue)
        
        event.on(2)
        XCTAssertEqual("2", actualValue)
    }
    
    func test_observableFlatMap() {
        let expectation = self.expectation(description: #function)
        let event = Event<Int>()
        
        func generateEvent(_ value: Int) -> Event<String> {
            let event = Event<String>()
            DispatchQueue.main.async {
                event.on(String(value))
            }
            return event
        }
        
        var actualValue: String?
        
        event.flatMap {
            generateEvent($0)
        }.subscribe {
            actualValue = $0
            expectation.fulfill()
        }
        
        XCTAssertNil(actualValue)
        
        event.on(1)
        waitForExpectations(timeout: 1)
        XCTAssertEqual("1", actualValue)
    }
    
    func test_observableFlatMapInternallyUsesColdSignalsWithColdSingle() {
        let event = Event<Int>()
        let event2 = Event<String>()
        
        var actualValue: String?
        var observedCount = 0
        
        event.flatMap { _ in
            event2
        }.subscribe {
            actualValue = $0
            observedCount += 1
        }

        event.on(1)
        XCTAssertNil(actualValue)
        XCTAssertEqual(0, observedCount)

        event2.on("1")
        XCTAssertEqual("1", actualValue)
        XCTAssertEqual(1, observedCount)
        
        // event2's current value is still "1" and event triggers subscription
        event.on(2)
        XCTAssertEqual("1", actualValue)
        XCTAssertEqual(2, observedCount)

        // event2's ColdSingle is disposed, so this event goes unnoticed to the subscription
        event2.on("2")
        XCTAssertEqual("1", actualValue)
        XCTAssertEqual(2, observedCount)

        // event3 triggers the single event, using event2's current value and triggers the subscription
        event.on(3)
        XCTAssertEqual("2", actualValue)
        XCTAssertEqual(3, observedCount)

        // event2's ColdSingle is disposed, so this event goes unnoticed
        event2.on("3")
        XCTAssertEqual("2", actualValue)
        XCTAssertEqual(3, observedCount)
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
    
    func test_combineFilterMap() {
        struct AuthenticationCredentials {
            let email: String
            let password: String
            
            init(email: String, password: String) {
                self.email = email
                self.password = password
            }
        }
        
        func isValidEmail(_ email: String) -> Bool {
            return email.count > 0
        }
        
        func isValidPassword(_ password: String) -> Bool {
            return password.count >= 8 &&
                password.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
        }
        
        let emailEvent = Event<String>()
        let passwordEvent = Event<String>()
        
        let validAuthCredentials = Observable<AuthenticationCredentials>
            .combine(
                emailEvent.filter(isValidEmail),
                passwordEvent.filter(isValidPassword)
            ).map(AuthenticationCredentials.init)

        var credentials: AuthenticationCredentials?
        validAuthCredentials.subscribe {
            credentials = $0
        }
        
        emailEvent.on("")
        passwordEvent.on("1234567")
        XCTAssertNil(credentials)
        
        emailEvent.on("han.solo@falconware.net")
        XCTAssertNil(credentials)
        
        passwordEvent.on("chewb4cca")
        XCTAssertEqual("han.solo@falconware.net", credentials?.email)
        XCTAssertEqual("chewb4cca", credentials?.password)
        
        struct User {}
        
        func authenticate(_ auth: AuthenticationCredentials) -> Observable<User> {
            let event = Event<User>()
            // perform login network request, for example
            event.on(User())
            return event
        }
        
        var actualUser: User?
        
        validAuthCredentials
            .flatMap { authenticate($0) }
            .subscribeWithCurrentValue {
                actualUser = $0
            }
        
        XCTAssertNotNil(actualUser)
    }
}
