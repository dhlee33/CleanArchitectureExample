//
//  GitHubSearch.swift
//  CleanArchitectureExample
//
//  Created by 이동현 on 21/09/2019.
//  Copyright © 2019 이동현. All rights reserved.
//

struct GitHubSearch: Codable {
    var items: [GitHubSearchItem]
    var totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items = "items"
    }
}
