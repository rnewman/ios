/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

let ONE_YEAR_IN_SECONDS = 365 * 24 * 60 * 60;

/**
 * Immutable representation for Sync records.
 *
 * Envelopes consist of:
 *   Required: "id", "collection", "payload".
 *   Optional: "modified", "sortindex", "ttl".
 *
 * Deletedness is a property of the payload.
 */
@objc public class Record {
    let id: String
    let collection: String
    let payload: JSON

    let modified: Int
    let sortindex: Int
    let ttl: Int              // Seconds.

    init(id: String, collection: String, payload: JSON, modified: Int = time(nil), sortindex: Int = 0, ttl: Int = ONE_YEAR_IN_SECONDS) {
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
        //return equalIdentifiers(rec) && rec.deleted == self.deleted
        return equalIdentifiers(rec)
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
