//
//  Group.swift
//  Call Me Out
//
//  Created by B S on 4/18/18.
//  Copyright © 2018 B S. All rights reserved.
//

import Foundation

class Group {
    var id:String
    var name:String
    var creator:String
    var member:String
    
    init(id:String, name:String, creator:String,member:String) {
        self.id = id
        self.name = name
        self.creator = creator
        self.member = member
    }
}
