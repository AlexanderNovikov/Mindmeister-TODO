//
//  ApiResponseError.swift
//  Mindmeister TODO
//
//  Created by Alexander Novikov on 28.04.2020.
//  Copyright © 2020 novikovav. All rights reserved.
//

import Foundation

struct ApiResponseError: Decodable {
    var code: Int?
    var msg: String?
}
