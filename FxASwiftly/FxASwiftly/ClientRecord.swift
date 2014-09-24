/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation


@objc public class ClientPayload : PayloadJSON {
    public func isValid() -> Bool {
        return self["name"].isString &&
               self["commands"].isArray &&
               self["type"].isString
    }

    var commands: [JSON] {
        return self["commands"].asArray!
    }

    var name: String {
        return self["name"].asString!
    }

    var clientType: String {
        return self["type"].asString!
    }
    
    override public func equalPayloads(obj: PayloadJSON) -> Bool {
        if !(obj is ClientPayload) {
            return false;
        }

        if !super.equalPayloads(obj) {
            return false;
        }

        let p = obj as ClientPayload
        if p.name != self.name {
            return false
        }
        
        if p.clientType != self.clientType {
            return false;
        }

        return true
    }

    // TODO: version, protocols.
}
