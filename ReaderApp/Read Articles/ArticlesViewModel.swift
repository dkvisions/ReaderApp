//
//  ArticlesViewModel.swift
//  ReaderApp
//
//  Created by Rahul on 13/09/25.
//

import Foundation
import Network


enum ResponseStatus {
    case loading(Bool)
    case success
    case failed(ResponseError)
}

class ArticlesViewModel: NSObject {
    
    var completion: ((ResponseStatus) -> ())?
    
    var articlesModelData: ArticlesModel? {
        didSet {
            completion?(.success)
        }
    }
    
    func fetchArticles(source: String) {
        completion?(.loading(true))
        
        Task {
            let urlString = Constants.baseURL + source + "&apiKey=\(Constants.apiKey)"
            
            guard let url = URL(string: urlString) else {
                completion?(.failed(.notReachable))
                completion?(.loading(false))
                return
            }
            
            let result = await NetworkManager.shared.request(ArticlesModel.self, from: url)
            
            switch result {
            case .success(let model):
                if model.articles?.isEmpty == true {
                    completion?(.failed(.noDataFound))
                } else {
                    self.articlesModelData = model
                    fetchAndSetBookMarked()
                    CoreDataManager.shared.saveArticles(model.articles ?? [])
                }
            case .failure(let error):
                completion?(.failed(error))
            }
            
            completion?(.loading(false))
        }
    }
    
    func fetchAndSetBookMarked() {
        guard let articles = articlesModelData?.articles, !articles.isEmpty else { return }
        
        let bookmarkedArticles = CoreDataManager.shared.fetchBookmarkedArticles()
        let bookmarkedSet = Set(bookmarkedArticles.compactMap { $0.publishedAt })
        
        for (index, article) in articles.enumerated() {
            if let publishedAt = article.publishedAt, bookmarkedSet.contains(publishedAt) {
                articlesModelData?.articles?[index].isBookMark = true
            }
        }
    }
}
