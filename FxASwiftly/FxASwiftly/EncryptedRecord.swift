/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

public class KeyBundle {
    let encKey: NSData;
    let hmacKey: NSData;

    public init(encKey: NSData, hmacKey: NSData) {
        self.encKey = encKey
        self.hmacKey = hmacKey
    }

    public func hmac(ciphertext: NSData) -> String {
        let hmacAlgorithm = CCHmacAlgorithm(kCCHmacAlgSHA256)
        let digestLen: Int = Int(CC_SHA256_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        CCHmac(hmacAlgorithm, hmacKey.bytes, UInt(hmacKey.length), ciphertext.bytes, UInt(ciphertext.length), result)
        var hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }

        result.destroy()

        return String(hash)
    }

    // You *must* verify HMAC before calling this.
    public func decrypt(ciphertext: NSData, iv: NSData) -> String? {
        return "{\"decrypted\": true}"

    }

    public func verify(hmac: NSData, iv: NSData) -> Bool {
        return true
    }
}

public class Keys {
    public init() {
        
    }

    // TODO
    public func forCollection(collection: String) -> KeyBundle {
        return KeyBundle(encKey: NSData(), hmacKey: NSData())
    }

    public func factory<T : CleartextPayloadJSON>(collection: String) -> (String) -> T? {
        let bundle = forCollection(collection)
        return { (payload: String) -> T? in
            let potential = EncryptedJSON(json: payload, keyBundle: bundle)
            if !(potential.isValid()) {
                return nil
            }

            let cleartext = potential.cleartext
            if (cleartext == nil) {
                return nil
            }
            return T(cleartext!)
        }
    }
}

/**
 * Turns JSON of the form
 *
 *  { ciphertext: ..., hmac: ..., iv: ...}
 *
 * into a new JSON object resulting from decrypting and parsing the ciphertext.
 */
public class EncryptedJSON : JSON {
    var _cleartext: JSON?               // Cache decrypted cleartext.
    var _ciphertextBytes: NSData?       // Cache decoded ciphertext.
    var _hmacBytes: NSData?             // Cache decoded HMAC.
    var _ivBytes: NSData?               // Cache decoded IV.

    var valid: Bool = false
    var validated: Bool = false

    let keyBundle: KeyBundle

    public init(json: String, keyBundle: KeyBundle) {
        self.keyBundle = keyBundle
        super.init(JSON.parse(json))
    }
    
    public init(json: JSON, keyBundle: KeyBundle) {
        self.keyBundle = keyBundle
        super.init(json)
    }
    
    private func validate() -> Bool {
        if validated {
            return valid
        }

        validated = true
        valid = isValid() && keyBundle.verify(self.hmac, iv: self.iv)
        return valid
    }

    public func isValid() -> Bool {
        return !isError &&
               self["ciphertext"].isString &&
               self["hmac"].isString &&
               self["IV"].isString &&
               self.validate()
    }

    func fromBase64(str: String) -> NSData {
        let b = NSData(base64EncodedString: str, options: NSDataBase64DecodingOptions.allZeros)
        println("Base64 \(str) yielded \(b)")
        return b
    }

    var ciphertext: NSData {
        if (_ciphertextBytes != nil) {
            return _ciphertextBytes!
        }

        _ciphertextBytes = fromBase64(self["ciphertext"].asString!)
        return _ciphertextBytes!
    }
    
    var hmac: NSData {
        if (_hmacBytes != nil) {
            return _hmacBytes!
        }
            
        _hmacBytes = fromBase64(self["hmac"].asString!)
        return _hmacBytes!
    }

    var iv: NSData {
        if (_ivBytes != nil) {
            return _ivBytes!
        }
            
        _ivBytes = fromBase64(self["iv"].asString!)
        return _ivBytes!
    }

    // Returns nil on error.
    public var cleartext: JSON? {
        if (_cleartext != nil) {
            return _cleartext
        }

        if (!validate()) {
            println("Failed to validate.")
            return nil
        }

        let decrypted: String? = keyBundle.decrypt(self.ciphertext, iv: self.iv)
        if (decrypted == nil) {
            println("Failed to decrypt.")
            valid = false
            return nil
        }

        _cleartext = JSON.parse(decrypted!)
        return _cleartext!
    }
}