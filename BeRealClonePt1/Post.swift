//
//  Post.swift
//  BeRealClonePt1
//
//  Created by Nakisha S. on 9/24/25.
//

import Foundation
import ParseSwift

struct Post: ParseObject {

    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    var caption: String?
    var user: User?
    var imageFile: ParseFile?
    var authorUsername: String?

    var takenAt: Date?
    var latitude: Double?
    var longitude: Double?
    var locationName: String?
}
