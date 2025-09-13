//
//  Constants.swift
//  ReaderApp
//
//  Created by Rahul on 13/09/25.
//

import UIKit


struct Constants {
    static let apiKey = "d94e26188bae4e19ab77649e41df6727"
    static let baseURL = "https://newsapi.org/v2/top-headlines?sources="
    
    static let newsSources: [(sourceName: String, sourceKey: String)] = [
        ("BBC News", "bbc-news"),
        ("Bleacher Report", "bleacher-report"),
        ("Business Insider", "business-insider"),
        ("CNN", "cnn"),
        ("Engadget", "engadget"),
        ("ESPN", "espn"),
        ("Fox News", "fox-news"),
        ("Fox Sports", "fox-sports"),
        ("Google News", "google-news"),
        ("IGN", "ign"),
        ("Independent", "independent"),
        ("Medical News Today", "medical-news-today"),
        ("National Geographic", "national-geographic"),
        ("Newsweek", "newsweek"),
        ("New York Magazine", "new-york-magazine"),
        ("Politico", "politico"),
        ("TechCrunch", "techcrunch"),
        ("TechRadar", "techradar"),
        ("The Hill", "the-hill"),
        ("The Hindu", "the-hindu"),
        ("The Times of India", "the-times-of-india"),
        ("The Verge", "the-verge"),
        ("Wired", "wired")
    ]

}



struct AppCommonFunctions {
    
    static func showToast(view: UIView, _ message: String) {
        let toast = UILabel()
        toast.text = message
        toast.textAlignment = .center
        toast.font = .systemFont(ofSize: 14)
        toast.textColor = .white
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toast.numberOfLines = 0
        toast.layer.cornerRadius = 8
        toast.layer.masksToBounds = true
        
        let padding: CGFloat = 16
        let maxWidth = view.frame.width - 40
        let size = toast.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        
        toast.frame = CGRect(
            x: 20,
            y: view.frame.height - size.height - 100,
            width: maxWidth,
            height: size.height + padding
        )
        
        view.addSubview(toast)
        
        UIView.animate(withDuration: 0.5, delay: 2, options: .curveEaseOut, animations: {
            toast.alpha = 0
        }) { _ in
            toast.removeFromSuperview()
        }
    }
    
    static func formateDate(dateString: String) -> String {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime]
        
        let date = inputFormatter.date(from: dateString) ?? Date()
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy hh:mm a"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return outputFormatter.string(from: date)
        
    }
}
