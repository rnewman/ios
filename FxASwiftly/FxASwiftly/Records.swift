/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

let ONE_YEAR_IN_SECONDS = 365 * 24 * 60 * 60;

public class EnvelopeJSON : JSON {
    public init(_ jsonString: String) {
        super.init(JSON.parse(jsonString))
    }

    override public init(_ json: JSON) {
        super.init(json)
    }

    public func isValid() -> Bool {
        return !isError &&
               self["id"].isString &&
               self["collection"].isString &&
               self["payload"].isString
    }

    public var id: String {
        return self["id"].asString!
    }
    
    public var collection: String {
        return self["collection"].asString!
    }
    
    public var payload: String {
        return self["payload"].asString!
    }
}

public class PayloadJSON : JSON {
    public init(_ jsonString: String) {
        super.init(JSON.parse(jsonString))
    }

    override public init(_ json: JSON) {
        super.init(json)
    }

    // Override me.
    public func isValid() -> Bool {
        return !isError
    }

    public var deleted: Bool {
        let d = self["deleted"]
        if d.isBool {
            return d.asBool!
        } else {
            return false;
        }
    }

    // Override me.
    public func equalPayloads (obj: PayloadJSON) -> Bool {
        return self.deleted == obj.deleted
    }
}

/**
 * Immutable representation for Sync records.
 *
 * Envelopes consist of:
 *   Required: "id", "collection", "payload".
 *   Optional: "modified", "sortindex", "ttl".
 *
 * Deletedness is a property of the payload.
 */
@objc public class Record<T : PayloadJSON> {
    let id: String
    let collection: String
    let payload: T

    let modified: Int
    let sortindex: Int
    let ttl: Int              // Seconds.

    // This is a hook for decryption.
    // Right now it only parses the string. In subclasses, it'll parse the
    // string, decrypt the contents, and return the data as a JSON object.
    public class func payloadFromPayloadString(payload: String) -> T {
        return T(payload)
    }

    // TODO: consider using error tuples.
    public class func fromEnvelope(envelope: EnvelopeJSON) -> Record<T>? {
        if envelope.isValid() {
            let payload = payloadFromPayloadString(envelope.payload)
            if payload.isValid() {
                return Record<T>(envelope: envelope, payload: payload)
            } else {

                println("Invalid payload \(payload.toString(pretty: true)).")
            }
        } else {

            println("Invalid envelope.")
        }
        return nil
    }

    /**
     * Accepts an envelope and a decrypted payload.
     * Inputs are not validated. Use `fromEnvelope` above.
     */
    convenience init(envelope: EnvelopeJSON, payload: T) {
        // TODO: modified, sortindex, ttl
        self.init(id: envelope.id, collection: envelope.collection, payload: payload)
    }

    init(id: String, collection: String, payload: T, modified: Int = time(nil), sortindex: Int = 0, ttl: Int = ONE_YEAR_IN_SECONDS) {
        self.id = id
        self.collection = collection

        self.payload = payload;

        self.modified = modified
        self.sortindex = sortindex
        self.ttl = ttl
    }
    
    func equalIdentifiers(rec: Record) -> Bool {
        return rec.collection == self.collection &&
               rec.id == self.id
    }
    
    // Override me.
    func equalPayloads(rec: Record) -> Bool {
        return equalIdentifiers(rec) && rec.payload.deleted == self.payload.deleted
    }
    
    func equals(rec: Record) -> Bool {
        return rec.sortindex == self.sortindex &&
               rec.modified == self.modified &&
               equalPayloads(rec)
    }

    public class func generateGUID() -> String {
        let data = NSMutableData(length: 9)
        let bytes = UnsafeMutablePointer<UInt8>(data.mutableBytes)
        let result: Int32 = SecRandomCopyBytes(kSecRandomDefault, 9, bytes)

        assert(result == 0, "Random byte generation failed.");

        return data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
    }
}