//
//  ObjectionNode.swift
//  Defensio
//
//  Created by Nick Morris on 1/9/25.
//

import Foundation
import FirebaseFirestore

struct ObjectionNode: Identifiable, Codable {
    var id: String
    var body: String?
    var children: [ObjectionNode]  // ✅ Fully resolved children here
    var children_order: [String]
    var index: Int?
    var notes: String?
    var parent_id: String?
    var title: String
    var visible: Bool
}
