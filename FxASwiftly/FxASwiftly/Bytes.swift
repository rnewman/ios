/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

/**
 * Utilities for futzing with bytes and such.
 */
public class Bytes {
    public class func generateRandomBytes(len: UInt) -> NSData {
        let data = NSMutableData(length: Int(len))
        let bytes = UnsafeMutablePointer<UInt8>(data.mutableBytes)
        let result: Int32 = SecRandomCopyBytes(kSecRandomDefault, len, bytes)
        
        assert(result == 0, "Random byte generation failed.");
        return data
    }
    
    public class func generateGUID() -> String {
        return generateRandomBytes(9).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
    }
    
    public class func decodeBase64(b64: String) -> NSData {
        return NSData(base64EncodedString: b64,
                      options: NSDataBase64DecodingOptions.allZeros)
    }
    
    func fromHex(str: String) -> NSData {
       // TODO
        return NSData()
    }
}