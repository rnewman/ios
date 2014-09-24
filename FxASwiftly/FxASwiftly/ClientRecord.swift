/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation


/*
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
    
    init(envelope: [String: AnyObject]) {
        super.init(envelope: envelope)
    }
    
    init(payload: [String: AnyObject]) {
        super.init(payload: payload)
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
    
    public class func initFromPayload(obj: [String: AnyObject]) -> ClientRecord {
        let name = obj["name"] as AnyObject? as? String
        let type = obj["type"] as AnyObject? as? String
        let commands = obj["commands"] as AnyObject? as? [String: AnyObject]
    }
    
    public class func initFromPayloadString(str: String) -> ClientRecord {
        // TODO: this is all very unsafe.
        let data: NSData! = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var error: NSError?
        let json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error)
        if let parsed = json as? [String: AnyObject] {
            return initFromPayload(parsed)
        }
    }
}
*/
