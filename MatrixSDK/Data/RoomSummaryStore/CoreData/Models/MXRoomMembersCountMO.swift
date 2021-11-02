// 
// Copyright 2021 The Matrix.org Foundation C.I.C
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import CoreData

@objc(MXRoomMembersCountMO)
public class MXRoomMembersCountMO: NSManagedObject {
    
    internal static func typedFetchRequest() -> NSFetchRequest<MXRoomMembersCountMO> {
        return NSFetchRequest<MXRoomMembersCountMO>(entityName: entityName)
    }

    @NSManaged public var s_members: Int16
    @NSManaged public var s_joined: Int16
    @NSManaged public var s_invited: Int16
    
    @discardableResult
    internal static func insert(roomMembersCount membersCount: MXRoomMembersCount,
                                into moc: NSManagedObjectContext) -> MXRoomMembersCountMO {
        let model = MXRoomMembersCountMO(context: moc)
        
        model.s_members = Int16(membersCount.members)
        model.s_joined = Int16(membersCount.joined)
        model.s_invited = Int16(membersCount.invited)
        
        return model
    }
    
}