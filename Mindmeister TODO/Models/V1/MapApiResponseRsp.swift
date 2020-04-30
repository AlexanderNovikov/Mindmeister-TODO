//
//  MapApiResponseRsp.swift
//  Mindmeister TODO
//
//  Created by Alexander Novikov on 28.04.2020.
//  Copyright © 2020 novikovav. All rights reserved.
//

import Foundation

class MapApiResponseRsp: ApiResponseRsp {
    var ideas: MapIdeas?
    
    private enum CodingKeys: String, CodingKey {
        case ideas
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ideas = try container.decode(MapIdeas.self, forKey: .ideas)
        try super.init(from: decoder)
    }
}

class MapIdeas: Decodable {
    var idea: [String:[MapIdea]] = [String:[MapIdea]]()
    
    private enum CodingKeys: String, CodingKey {
        case idea
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let ideas = try container.decode([MapIdea]?.self, forKey: .idea) {
            for idea in ideas {
                if let parentId = idea.parent {
                    if (self.idea[parentId] == nil) {
                        self.idea[parentId] = [MapIdea]()
                    }
                    self.idea[parentId]?.append(idea)
                }
            }
        }
    }
    
    public func getIdeasByParentId(parentId: String) -> [MapIdea]? {
        return self.idea[parentId]
    }
}

class MapIdea: Decodable {
    public static let ICON_STATUS_OK = "status_ok"
    
    var id: String?
    var title: String?
    var parent: String?
    var icon: String?
}
