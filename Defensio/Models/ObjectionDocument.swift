//
//  ObjectionDocument.swift
//  Defensio
//
//  Created by Nick Morris on 1/9/25.
//

import Foundation

struct ObjectionDocument: Identifiable, Codable {
    var id: String
    var body: String
    var children: [String]
    var children_order: [String]
    var index: Int?
    var notes: String
    var parent_id: String?  // Allowing it to be optional
    var title: String
    var visible: Bool
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            body = try container.decode(String.self, forKey: .body)
            children = try container.decode([String].self, forKey: .children)
            children_order = try container.decodeIfPresent([String].self, forKey: .children_order) ?? [] // ✅ Default to an empty array
            index = try container.decodeIfPresent(Int.self, forKey: .index)
            notes = try container.decode(String.self, forKey: .notes)
            parent_id = try container.decodeIfPresent(String.self, forKey: .parent_id)
            title = try container.decode(String.self, forKey: .title)
            visible = try container.decodeIfPresent(Bool.self, forKey: .visible) ?? true  // ✅ Default value set here
        }
}
