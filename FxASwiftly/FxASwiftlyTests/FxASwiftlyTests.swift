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

    func testRecord() {
        let invalidPayload = "{\"id\": \"abcdefghijkl\", \"collection\": \"clients\", \"payload\": \"invalid\"}"
        let emptyPayload = "{\"id\": \"abcdefghijkl\", \"collection\": \"clients\", \"payload\": \"{}\"}"

        let clientBody: [String: AnyObject] = ["name": "Foobar", "commands": [], "type": "mobile"]
        let clientBodyString = JSON(clientBody).toString(pretty: false)
        let clientRecord: [String : AnyObject] = ["id": "abcdefghijkl", "collection": "clients", "payload": clientBodyString]
        let clientPayload = JSON(clientRecord).toString(pretty: false)

        let cleartextClientsFactory: (String) -> ClientPayload? = {
            (s: String) -> ClientPayload? in
            return ClientPayload(s)
        }
        
        let ciphertextClientsFactory: (String) -> ClientPayload? = Keys().factory("clients")

        let clearFactory: (String) -> CleartextPayloadJSON? = {
            (s: String) -> CleartextPayloadJSON? in
            return CleartextPayloadJSON(s)
        }

        println(clientPayload)

        // Only payloads that parse as JSON are valid.
        XCTAssertNil(Record<CleartextPayloadJSON>.fromEnvelope(EnvelopeJSON(invalidPayload), payloadFactory: clearFactory))
        XCTAssertNotNil(Record<CleartextPayloadJSON>.fromEnvelope(EnvelopeJSON(emptyPayload), payloadFactory: clearFactory))

        // Only valid ClientPayloads are valid.
        XCTAssertNil(Record<ClientPayload>.fromEnvelope(EnvelopeJSON(invalidPayload), payloadFactory: cleartextClientsFactory))
        XCTAssertNotNil(Record<ClientPayload>.fromEnvelope(EnvelopeJSON(clientPayload), payloadFactory: cleartextClientsFactory))
    }
}
