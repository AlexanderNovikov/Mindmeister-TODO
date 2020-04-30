//
//  MMMap.swift
//  Mindmeister TODO
//
//  Created by Alexander Novikov on 27.04.2020.
//  Copyright © 2020 novikovav. All rights reserved.
//

import Foundation

class MapListApiResponseRsp: ApiResponseRsp {
    var maps: MapListMaps?
    
    private enum CodingKeys: String, CodingKey {
        case maps
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maps = try container.decode(MapListMaps.self, forKey: .maps)
        try super.init(from: decoder)
    }
}

struct MapListMaps: Decodable {
    var map: [MapListMap]?
}

struct MapListMap: Decodable {
    var id: String?
    var title: String?
}
