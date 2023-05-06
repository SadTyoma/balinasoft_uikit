//
//  ListItem.swift
//  balinasoft_uikit
//
//  Created by Artem Shuneyko on 6.05.23.
//

import Foundation

struct ListItem: Codable, Identifiable {
    let id: Int
    let name: String
    let image: String?
}

struct APIResult: Codable {
    let page: Int
    let pageSize: Int
    let totalPages: Int
    let totalElements: Int
    let content: [ListItem]
}
