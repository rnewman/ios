/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

public class KeyBundle {
    // You *must* verify HMAC before calling this.
    public func decrypt(ciphertext: NSData, iv: NSData) -> String? {
        return "{\"decrypted\": true}"
    }
}

public class Keys {
    // TODO
    public func forCollection(collection: String) -> KeyBundle {
        return KeyBundle()
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

        // TODO: check the HMAC!!!!!!!!!!!!!. Seriously.
        validated = true
        valid = true
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
         return NSData(base64EncodedString: str, options: NSDataBase64DecodingOptions.allZeros)
    }

    var ciphertext: NSData {
        if (_ciphertextBytes != nil) {
            return _ciphertextBytes!
        }

        _ciphertextBytes = fromBase64(self["ciphertext"].asString!)
        return _ciphertextBytes!
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
            return nil
        }

        let decrypted: String? = keyBundle.decrypt(self.ciphertext, iv: self.iv)
        if (decrypted == nil) {
            valid = false
            return nil
        }

        _cleartext = JSON.parse(decrypted!)
        return _cleartext!
    }

}

public class EncryptedRecord<T : CleartextPayloadJSON> : Record<T> {
    // The payload of a BSO is a string representation of a JSON object.
    // The contents of the JSON object are arguments to a decryption operation.
    // The result is the decrypted payload.
    override public class func payloadFromPayloadString(envelope: EnvelopeJSON, payload: String) -> T? {
        let keys = Keys() // TODO
        let keyBundle = keys.forCollection(envelope.collection)
        let cleartext = EncryptedJSON(json: payload, keyBundle: keyBundle).cleartext
        if (cleartext == nil) {
            return nil
        }
        return T(cleartext!)
    }
}