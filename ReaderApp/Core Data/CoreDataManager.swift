//
//  CoreDataManager.swift
//  ReaderApp
//
//  Created by Rahul on 13/09/25.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "ReaderApp") // your xcdatamodeld name
        persistentContainer.loadPersistentStores { (desc, error) in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed saving context: \(error)")
            }
        }
    }
    
    
    func saveArticles(_ articles: [ArticlesModelElement]) {
        let context = CoreDataManager.shared.context
        
        // 1️⃣ Fetch all existing articles (bookmarked or not)
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        
        var existingArticles: [String: ArticleEntity] = [:]
        do {
            let results = try context.fetch(fetchRequest)
            for entity in results {
                if let publishedAt = entity.publishedAt {
                    existingArticles[publishedAt] = entity
                }
            }
        } catch {
            print("Failed to fetch existing articles: \(error)")
        }
        
        // 2️⃣ Upsert articles from API
        for article in articles {
            guard let pubAt = article.publishedAt else { continue }
            
            if let existing = existingArticles[pubAt] {
                // 🔄 Update existing article
                existing.name = article.source?.name
                existing.author = article.author
                existing.title = article.title
                existing.desc = article.description
                existing.url = article.url
                existing.urlToImage = article.urlToImage
                existing.content = article.content
                existing.sourceID = article.source?.id
                // ⚠️ Do NOT reset isBookMark (keep user choice)
            } else {
                // ➕ Insert new article
                let entity = ArticleEntity(context: context)
                entity.name = article.source?.name
                entity.author = article.author
                entity.title = article.title
                entity.desc = article.description
                entity.url = article.url
                entity.urlToImage = article.urlToImage
                entity.publishedAt = article.publishedAt
                entity.content = article.content
                entity.isBookMark = article.isBookMark ?? false
                entity.sourceID = article.source?.id
            }
        }
        
        // 3️⃣ Save changes
        CoreDataManager.shared.saveContext()
    }


    
    func saveArticles1(_ articles: [ArticlesModelElement]) {
        let context = CoreDataManager.shared.context
        
        // 1️⃣ Fetch existing bookmarks
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isBookMark == true")
        
        var bookmarks: [ArticleEntity] = []
        do {
            bookmarks = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch bookmarks: \(error)")
        }
        
        // 2️⃣ Create a Set of bookmarked publishedAt for quick lookup
        let bookmarkedSet = Set(bookmarks.compactMap { $0.publishedAt })
        
        // 3️⃣ Delete all non-bookmarked articles
        let deleteRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        deleteRequest.predicate = NSPredicate(format: "isBookMark == false")
        
        do {
            let toDelete = try context.fetch(deleteRequest)
            for article in toDelete {
                context.delete(article)
            }
        } catch {
            print("Failed to delete non-bookmarked articles: \(error)")
        }
        
        // 4️⃣ Insert or update API articles
        for article in articles {
            // If this article is already bookmarked, skip inserting to avoid duplicate
            if let publishedAt = article.publishedAt, bookmarkedSet.contains(publishedAt) {
                continue
            }
            
            // Insert new article
            let entity = ArticleEntity(context: context)
            entity.name = article.source?.name
            entity.author = article.author
            entity.title = article.title
            entity.desc = article.description
            entity.url = article.url
            entity.urlToImage = article.urlToImage
            entity.publishedAt = article.publishedAt
            entity.content = article.content
            entity.isBookMark = article.isBookMark ?? false
            entity.sourceID = article.source?.id
        }
        
        // 5️⃣ Save all changes
        CoreDataManager.shared.saveContext()
    }


    
    
    func fetchBookmarkedArticles() -> [ArticlesModelElement] {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        
        // Only fetch where isBookMark is true
        fetchRequest.predicate = NSPredicate(format: "isBookMark == true")
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.map { entity in
                ArticlesModelElement(
                    source: ArticleSource(id: entity.sourceID, name: entity.name),
                    author: entity.author,
                    title: entity.title,
                    description: entity.desc,
                    url: entity.url,
                    urlToImage: entity.urlToImage,
                    publishedAt: entity.publishedAt,
                    content: entity.content,
                    isBookMark: entity.isBookMark
                )
            }
        } catch {
            print("Failed to fetch bookmarked articles: \(error)")
            return []
        }
    }

    
    func fetchArticles() -> [ArticlesModelElement] {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.map { entity in
                ArticlesModelElement(                    
                    source: ArticleSource(id: entity.sourceID, name: entity.name),
                    author: entity.author,
                    title: entity.title,
                    description: entity.desc,
                    url: entity.url,
                    urlToImage: entity.urlToImage,
                    publishedAt: entity.publishedAt,
                    content: entity.content,
                    isBookMark: entity.isBookMark
                )
            }
        } catch {
            print("Failed to fetch articles: \(error)")
            return []
        }
    }

    
    func updateArticle(publishedAt: String, newArticle: ArticlesModelElement) {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "publishedAt == %@", publishedAt)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let entityToUpdate = results.first {
                // 🔄 Update existing article (but keep isBookMark unless user toggled)
                entityToUpdate.name = newArticle.source?.name
                entityToUpdate.author = newArticle.author
                entityToUpdate.title = newArticle.title
                entityToUpdate.desc = newArticle.description
                entityToUpdate.url = newArticle.url
                entityToUpdate.urlToImage = newArticle.urlToImage
                entityToUpdate.content = newArticle.content
                entityToUpdate.sourceID = newArticle.source?.id
                
                // ⚠️ Only update bookmark if explicitly set in newArticle
                if let isBookMark = newArticle.isBookMark {
                    entityToUpdate.isBookMark = isBookMark
                }
                
            } else {
                // ➕ Insert new article
                let entity = ArticleEntity(context: context)
                entity.name = newArticle.source?.name
                entity.author = newArticle.author
                entity.title = newArticle.title
                entity.desc = newArticle.description
                entity.url = newArticle.url
                entity.urlToImage = newArticle.urlToImage
                entity.publishedAt = newArticle.publishedAt // unique ID, set only on create
                entity.content = newArticle.content
                entity.isBookMark = newArticle.isBookMark ?? false
                entity.sourceID = newArticle.source?.id
            }
            
            CoreDataManager.shared.saveContext()
            
        } catch {
            print("❌ Failed to upsert article: \(error)")
        }
    }

    
    func updateArticle1(publishedAt: String, newArticle: ArticlesModelElement) {
        
        if newArticle.isBookMark == false {
            deleteArticle(publishedAt: publishedAt)
            return
        }
        
        
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        
       
        // Match by unique property (publishedAt)
        fetchRequest.predicate = NSPredicate(format: "publishedAt == %@", newArticle.publishedAt ?? "")
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let entityToUpdate = results.first {
                // Update existing article
                entityToUpdate.name = newArticle.source?.name
                entityToUpdate.author = newArticle.author
                entityToUpdate.desc = newArticle.description
                entityToUpdate.url = newArticle.url
                entityToUpdate.urlToImage = newArticle.urlToImage
                entityToUpdate.publishedAt = newArticle.publishedAt
                entityToUpdate.content = newArticle.content
                entityToUpdate.isBookMark = newArticle.isBookMark ?? false
            } else {
                // Add new article
                let entity = ArticleEntity(context: context)
                entity.name = newArticle.source?.name
                entity.author = newArticle.author
                entity.desc = newArticle.description
                entity.url = newArticle.url
                entity.urlToImage = newArticle.urlToImage
                entity.publishedAt = newArticle.publishedAt
                entity.content = newArticle.content
                entity.isBookMark = newArticle.isBookMark ?? false
                entity.sourceID = newArticle.source?.id
            }
            
            CoreDataManager.shared.saveContext()
            
        } catch {
            print("Failed to upsert article: \(error)")
        }
    }

    
    func deleteArticle(publishedAt: String) {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "publishedAt == %@", publishedAt)
        
        do {
            let results = try context.fetch(fetchRequest)
            for entity in results {
                context.delete(entity)
            }
            CoreDataManager.shared.saveContext()
        } catch {
            print("Failed to delete article: \(error)")
        }
    }
    
    func deleteAllArticles() {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ArticleEntity.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            for object in results {
                context.delete(object)
            }
            CoreDataManager.shared.saveContext()
           
        } catch {
            print("Failed to delete all articles: \(error)")
        }
    }

}
