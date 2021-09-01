//
//  RGroup.swift
//  Zotero
//
//  Created by Michal Rentka on 26/03/2019.
//  Copyright © 2019 Corporation for Digital Scholarship. All rights reserved.
//

import Foundation

import RealmSwift

enum GroupType: String {
    case `public` = "Public"
    case `private` = "Private"
}

final class RGroup: Object {
    @Persisted(primaryKey: true) var identifier: Int
    @Persisted var owner: Int
    @Persisted var name: String
    @Persisted var desc: String
    @Persisted var rawType: String
    @Persisted var canEditMetadata: Bool
    @Persisted var canEditFiles: Bool
    @Persisted var orderId: Int
    @Persisted var versions: RVersions?

    // MARK: - Sync data
    /// Flag that indicates that this group is kept only locally on this device, the group was either removed remotely
    // or the user was removed from the group, but the user chose to keep it
    @Persisted var isLocalOnly: Bool
    /// Indicates local version of object
    @Persisted var version: Int
    /// State which indicates whether object is synced with backend data, see ObjectSyncState for more info
    @Persisted var rawSyncState: Int

    // MARK: - Sync properties

    var syncState: ObjectSyncState {
        get {
            return ObjectSyncState(rawValue: self.rawSyncState) ?? .synced
        }

        set {
            self.rawSyncState = newValue.rawValue
        }
    }

    var type: GroupType {
        get {
            return GroupType(rawValue: self.rawType) ?? .private
        }

        set {
            self.rawType = newValue.rawValue
        }
    }
}
