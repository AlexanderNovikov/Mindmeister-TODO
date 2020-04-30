//
//  ApiResponse.swift
//  Mindmeister TODO
//
//  Created by Alexander Novikov on 28.04.2020.
//  Copyright © 2020 novikovav. All rights reserved.
//

import Foundation

struct ApiResponse<T:Decodable>: Decodable {
    var rsp: T?
}
