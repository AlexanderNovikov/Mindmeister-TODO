//
//  IdeasViewControllerSender.swift
//  Mindmeister TODO
//
//  Created by Alexander Novikov on 29.04.2020.
//  Copyright © 2020 novikovav. All rights reserved.
//

import Foundation

struct IdeasViewControllerSender {
    var mapId: String
    var mapIdeas: MapIdeas
    var parentId: String
    
    init(mapId: String, mapIdeas: MapIdeas, parendId: String) {
        self.mapId = mapId
        self.mapIdeas = mapIdeas
        self.parentId = parendId
    }
}
