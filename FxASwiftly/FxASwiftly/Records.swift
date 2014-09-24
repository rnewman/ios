/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

let ONE_YEAR_IN_SECONDS = 365 * 24 * 60 * 60;

/**
* Immutable representation for Sync records.
*/
@objc public class Record {
    let collection: String
    let deleted: Bool
    let guid: String
    let lastModified: Int
    let sortIndex: Int
    let ttl: Int              // Seconds.
    
    let localOnly: Bool
    
    init(guid: String, coll: String, deleted: Bool = false, lastModified: Int = time(nil), localOnly: Bool = false, ttl: Int = ONE_YEAR_IN_SECONDS, sortIndex: Int = 0) {
        self.guid = guid
        self.collection = coll
        self.deleted = deleted
        self.lastModified = lastModified
        self.localOnly = localOnly
        self.ttl = ttl
        self.sortIndex = sortIndex
    }
    
    func equalIdentifiers(rec: Record) -> Bool {
        return rec.collection == self.collection &&
               rec.guid == self.guid
    }
    
    // Override me.
    func equalPayloads(rec: Record) -> Bool {
        return equalIdentifiers(rec) && rec.deleted == self.deleted
    }
    
    func equals(rec: Record) -> Bool {
        return rec.sortIndex == self.sortIndex &&
               rec.lastModified == self.lastModified &&
               equalPayloads(rec)
    }

    class public func generateGUID() -> String {
        let data = NSMutableData(length: 9)
        let bytes = UnsafeMutablePointer<UInt8>(data.mutableBytes)
        let result: Int32 = SecRandomCopyBytes(kSecRandomDefault, 9, bytes)

        assert(result == 0, "Random byte generation failed.");

        return data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
    }
}

@objc public class ClientRecord : Record {
    var commands: [String]     // TODO
    
    let name: String
    let type: String
    
    convenience init(name: String, type: String, guid: String, lastModified: Int) {
        self.init(name: name, type: type, guid: guid, deleted: false, lastModified: lastModified, localOnly: false)
    }
    
    init(name: String, type: String, guid: String, deleted: Bool, lastModified: Int, localOnly: Bool = false) {
        self.name = name
        self.commands = []
        self.type = type
        super.init(guid: guid, coll: "clients", deleted: false, lastModified: lastModified, localOnly: localOnly)
    }

    
    override func equalPayloads(rec: Record) -> Bool {
        if !(rec is ClientRecord) {
            return false
        }

        let r: ClientRecord = rec as ClientRecord
        if r.name != self.name {
            return false
        }

        if r.type != self.type {
            return false;
        }
        
        return super.equalPayloads(rec)
    }

    override func equals(rec: Record) -> Bool {
        if !(rec is ClientRecord) {
            return false
        }
        return super.equals(rec)
    }
}
