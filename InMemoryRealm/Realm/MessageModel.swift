//
//  MessageModel.swift
//  InMemoryRealm
//
//  Created by Muhand Jumah on 12/22/20.
//

import RealmSwift

final class MessageRealmEntity: Object {
    @objc dynamic var id: Int = Int.random(in: 1...1000)
    @objc dynamic var message: String = ""

    convenience init(message: String) {
        self.init()
        self.message = message
    }
    
    override static func primaryKey() -> String? {
        "id"
    }
}
