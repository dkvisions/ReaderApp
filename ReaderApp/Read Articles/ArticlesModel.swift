//
//  ArticlesModel.swift
//  ReaderApp
//
//  Created by Rahul on 13/09/25.
//

import Foundation

// MARK: - ArticlesModel
struct ArticlesModel: Codable {
    let status: String?
    let totalResults: Int?
    var articles: [ArticlesModelElement]?
}

// MARK: - Article
struct ArticlesModelElement: Codable {
    let source: ArticleSource?
    let author, title, description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    var isBookMark: Bool? = false
}

// MARK: - Source
struct ArticleSource: Codable {
    let id: String?
    let name: String?
}
