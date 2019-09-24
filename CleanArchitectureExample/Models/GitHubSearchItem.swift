//
//  GitHubSearchResponse.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 21/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

struct GitHubSearchItem: Codable {
    var fullName: String
    var star: Int
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case star = "stargazers_count"
    }
}
