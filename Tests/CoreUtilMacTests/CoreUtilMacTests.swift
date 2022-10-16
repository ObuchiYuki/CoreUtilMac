import XCTest
@testable import CoreUtilMac

final class CoreUtilClassTests: XCTestCase {
    func test_Action() throws {
        var value = 0
        let action = Action(title: "Hello", action: {
            value = 1
        })
        action()
        
        XCTAssertEqual(value, 1)
    }
    
    func test_Delta_map() throws {
        let by24 = Delta.by(12)
            .map{ $0 + 12 }
        
        var value = 12
        by24.apply(&value)
        XCTAssertEqual(value, 36)
        
        let to24 = Delta.to(12)
            .map{ $0 + 12 }
        
        to24.apply(&value)
        XCTAssertEqual(value, 24)
    }
    func test_Delta_encode() throws {
        let encoder = JSONEncoder()
        
        do {
            let by12 = Delta.by(12)
            let data = try encoder.encode(by12)
            let content = try XCTUnwrap(String(data: data, encoding: .utf8))
            
            XCTAssertEqual(content, #"{"by":12}"#)
        }
        do {
            let to12 = Delta.to(12)
            let data = try encoder.encode(to12)
            let content = try XCTUnwrap(String(data: data, encoding: .utf8))
            
            XCTAssertEqual(content, #"{"to":12}"#)
        }
    }
    
    func test_Delta_decode() throws {
        let decoder = JSONDecoder()
        do {
            let data = #"{"by": 12}"#.data(using: .utf8)!
            let delta = try decoder.decode(Delta<Int>.self, from: data)
            XCTAssertEqual(delta, .by(12))
        }
        do {
            let data = #"{"by": 12}"#.data(using: .utf8)!
            let delta = try decoder.decode(Delta<Int>.self, from: data)
            XCTAssertEqual(delta, .by(12))
        }
    }
    
    func test_NS_OnAwake() throws {
        class View: NSLoadView {
            static var onAwakeCalled = false
            override func onAwake() {
                View.onAwakeCalled = true
            }
        }
        XCTAssertFalse(View.onAwakeCalled)
        _ = View()
        XCTAssertTrue(View.onAwakeCalled)
    }
    
    func test_NSViewController_ChainObject_Call() throws {
        enum TestState {
            static var chainObjectDidSetCalled = false
            static var chainObjectDidLoadCalled = false
        }
        
        class ViewController: NSViewController {
            override var chainObject: Any? {
                didSet { TestState.chainObjectDidSetCalled = true }
            }
            override func chainObjectDidLoad() { TestState.chainObjectDidLoadCalled = true }
        }
        
        let vc = ViewController()
        vc.chainObject = "Hello World"
        
        XCTAssertTrue(TestState.chainObjectDidSetCalled)
        XCTAssertTrue(TestState.chainObjectDidLoadCalled)
    }
    
    func test_NSViewController_ChainObject_Chain() throws {
        enum TestState {
            static var parentLoadCalled = false
            static var childLoadCalled = false
        }
        
        class ParentViewController: NSViewController {
            override func chainObjectDidLoad() { TestState.parentLoadCalled = true }
        }
        class ChildViewController: NSViewController {
            override func chainObjectDidLoad() { TestState.childLoadCalled = true }
        }
        
        let parent = ParentViewController()
        let child = ChildViewController()
        parent.chainObject = "Hello World"
        XCTAssertTrue(TestState.parentLoadCalled)
        XCTAssertFalse(TestState.childLoadCalled)
        
        parent.addChild(child)
        XCTAssertTrue(TestState.parentLoadCalled)
        XCTAssertTrue(TestState.childLoadCalled)
    }
    
    func test_Observable() throws {
        enum TestState {
            static var sinkValue = -1
        }
        @Observable var value = 10
        
        XCTAssertEqual(value, 10)
        
        $value.sink{ TestState.sinkValue = $0 }.store(in: &objectBag)
        
        XCTAssertEqual(TestState.sinkValue, 10)
        value = 12
        XCTAssertEqual(TestState.sinkValue, 12)
    }
    
    func test_Publisher() throws {
        enum TestState {
            static var sinkValue = -1
        }
        
        let publisher = CurrentValueSubject<AnyPublisher<Int, Never>, Never>(Just(12).eraseToAnyPublisher())
        
        publisher
            .switchToLatest()
            .sink{ TestState.sinkValue = $0 }
            .store(in: &objectBag)
        
        XCTAssertEqual(TestState.sinkValue, 12)
        publisher.send(Just(23).eraseToAnyPublisher())
        XCTAssertEqual(TestState.sinkValue, 23)
    }
    
    func test_CombineLatestCollection() throws {
        enum TestState {
            static var sinkValue = [Int]()
        }
        let publishers = Array({ CurrentValueSubject<Int, Never>($0) }, count: 5)
        
        publishers.combineLatest
            .sink{ TestState.sinkValue = Array($0) }
            .store(in: &objectBag)
        
        XCTAssertEqual(TestState.sinkValue, [0, 1, 2, 3, 4])
        
        publishers[2].send(20)
        XCTAssertEqual(TestState.sinkValue, [0, 1, 20, 3, 4])
        
        publishers[1].send(10)
        XCTAssertEqual(TestState.sinkValue, [0, 10, 20, 3, 4])
    }
    
    func test_CombineLatestCollection_multiQueue() throws {
        enum TestState { static var sinkValue = [Int]() }
        
        let publishers = Array({ CurrentValueSubject<Int, Never>($0) }, count: 10)
        
        publishers.combineLatest
            .sink{ TestState.sinkValue = $0.map{ $0 } }.store(in: &objectBag)
        
        let exp = expectation(description: "wait") => { $0.expectedFulfillmentCount = 10 }
        
        for i in 0..<10 {
            DispatchQueue.global().async {
                publishers[i].send(i * 10)
                exp.fulfill()
            }
        }
        
        print(TestState.sinkValue)
                
        wait(for: [exp], timeout: 1)
        
        print(TestState.sinkValue)
    }
}

extension Array {
    init(_ generating: (Int) throws -> Element, count: Int) rethrows {
        self = try (0..<count).map(generating)
    }
}

