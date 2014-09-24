import UIKit
import XCTest
import FxASwiftly

class FxASwiftlyTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

    func testGUIDs() {
        let s = Record.generateGUID()
        println("Got GUID: \(s)")
        XCTAssertEqual(12, s.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    }

    func testEnvelopeJSON() {
        let e = EnvelopeJSON(JSON.parse("{}"))
        XCTAssertFalse(e.isValid())
        
        let ee = EnvelopeJSON("{\"id\": \"foo\"}")
        XCTAssertFalse(ee.isValid())
        XCTAssertEqual(ee.id, "foo")
        
        let eee = EnvelopeJSON(JSON.parse("{\"id\": \"foo\", \"collection\": \"bar\", \"payload\": \"baz\"}"))
        XCTAssertTrue(eee.isValid())
        XCTAssertEqual(eee.id, "foo")
        XCTAssertEqual(eee.collection, "bar")
        XCTAssertEqual(eee.payload, "baz")
    }
}
