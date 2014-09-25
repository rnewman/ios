import UIKit
import XCTest
import FxASwiftly

class CryptoTests: XCTestCase {
    let hmacB16 = "b1e6c18ac30deb70236bc0d65a46f7a4dce3b8b0e02cf92182b914e3afa5eebc"
    let ivB64 = "GX8L37AAb2FZJMzIoXlX8w=="

    let hmacKey = NSData(base64EncodedString: "MMntEfutgLTc8FlTLQFms8/xMPmCldqPlq/QQXEjx70=", options: NSDataBase64DecodingOptions.allZeros)
    let encKey = NSData(base64EncodedString: "9K/wLdXdw+nrTtXo4ZpECyHFNr4d7aYHqeg3KW9+m6Q=", options: NSDataBase64DecodingOptions.allZeros)

    
    let ciphertextB64 = "NMsdnRulLwQsVcwxKW9XwaUe7ouJk5Wn80QhbD80l0HEcZGCynh45qIbeYBik0lgcHbKmlIxTJNwU+OeqipN+/j7MqhjKOGIlvbpiPQQLC6/ffF2vbzL0nzMUuSyvaQzyGGkSYM2xUFt06aNivoQTvU2GgGmUK6MvadoY38hhW2LCMkoZcNfgCqJ26lO1O0sEO6zHsk3IVz6vsKiJ2Hq6VCo7hu123wNegmujHWQSGyf8JeudZjKzfi0OFRRvvm4QAKyBWf0MgrW1F8SFDnVfkq8amCB7NhdwhgLWbN+21NitNwWYknoEWe1m6hmGZDgDT32uxzWxCV8QqqrpH/ZggViEr9uMgoy4lYaWqP7G5WKvvechc62aqnsNEYhH26A5QgzmlNyvB+KPFvPsYzxDnSCjOoRSLx7GG86wT59QZw="

    let cleartextB64 = "eyJpZCI6IjVxUnNnWFdSSlpYciIsImhpc3RVcmkiOiJmaWxlOi8vL1VzZXJzL2phc29uL0xpYnJhcnkvQXBwbGljYXRpb24lMjBTdXBwb3J0L0ZpcmVmb3gvUHJvZmlsZXMva3NnZDd3cGsuTG9jYWxTeW5jU2VydmVyL3dlYXZlL2xvZ3MvIiwidGl0bGUiOiJJbmRleCBvZiBmaWxlOi8vL1VzZXJzL2phc29uL0xpYnJhcnkvQXBwbGljYXRpb24gU3VwcG9ydC9GaXJlZm94L1Byb2ZpbGVzL2tzZ2Q3d3BrLkxvY2FsU3luY1NlcnZlci93ZWF2ZS9sb2dzLyIsInZpc2l0cyI6W3siZGF0ZSI6MTMxOTE0OTAxMjM3MjQyNSwidHlwZSI6MX1dfQ=="

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHMAC() {
        let keyBundle = KeyBundle(encKey: encKey, hmacKey: hmacKey)
        // HMAC is computed against the Base64 ciphertext.
        let ciphertextRaw: NSData = (ciphertextB64.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false))!
        XCTAssertNotNil(ciphertextRaw)
        XCTAssertEqual(hmacB16, keyBundle.hmac(ciphertextRaw))
    }
    
    func testDecrypt() {
        let keyBundle = KeyBundle(encKey: encKey, hmacKey: hmacKey)
        // Decryption is done against raw bytes.
        let ciphertext = NSData(base64EncodedString: ciphertextB64,
                                options: NSDataBase64DecodingOptions.allZeros)
        let iv = NSData(base64EncodedString: ivB64,
                        options: NSDataBase64DecodingOptions.allZeros)
        let s = keyBundle.decrypt(ciphertext, iv: iv)
        let cleartext = NSString(data: NSData(base64EncodedString: cleartextB64,
                                              options: NSDataBase64DecodingOptions.allZeros),
                                 encoding: NSUTF8StringEncoding)
        XCTAssertTrue(cleartext.isEqualToString(s!))
    }
}
