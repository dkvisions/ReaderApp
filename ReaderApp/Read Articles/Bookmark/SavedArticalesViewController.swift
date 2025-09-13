//
//  SavedArticalesViewController.swift
//  ReaderApp
//
//  Created by Rahul on 13/09/25.
//

import UIKit

class SavedArticalesViewController: UIViewController {

    @IBOutlet weak var tableViewArticles: UITableView!
    
    @IBOutlet weak var labelNoRecords: UILabel!
    var articles: [ArticlesModelElement]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        articles = CoreDataManager.shared.fetchBookmarkedArticles()
        setUpTableView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        articles = CoreDataManager.shared.fetchBookmarkedArticles()
        tableViewArticles.reloadData()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



extension SavedArticalesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func setUpTableView() {
        let nib = UINib(nibName: ArticlesListTableViewCell.reuseIdentifier, bundle: nil)
        tableViewArticles.register(nib, forCellReuseIdentifier: ArticlesListTableViewCell.reuseIdentifier)
        tableViewArticles.delegate = self
        tableViewArticles.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = articles?.count ?? 0
        labelNoRecords.isHidden = count > 0
        return count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticlesListTableViewCell.reuseIdentifier) as? ArticlesListTableViewCell else {
            return UITableViewCell()
        }
        cell.buttonAddBookmark.tag = indexPath.row
        cell.buttonAddBookmark.addTarget(self, action: #selector(bookMarkTapped), for: .touchUpInside)
        cell.configureCell(data: articles?[indexPath.row])
        return cell
    }
    
    @objc func bookMarkTapped(_ sender: UIButton) {
        if var article = articles?[sender.tag] {
            let isBookMarked = article.isBookMark == false ? true : false
            
            
            if isBookMarked == false {
                showAlertForRemoving(article: article)
            }
            
        }
        
    }
    
    func showAlertForRemoving(article: ArticlesModelElement) {
        let alert = UIAlertController(
            title: "Remove Bookmark",
            message: "Do you want to remove this bookmark?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            if let index = articles?.firstIndex(where: {$0.publishedAt == article.publishedAt }) {
                articles?.remove(at: index)
                var article = article
                article.isBookMark = false
                CoreDataManager.shared.updateArticle(publishedAt: article.publishedAt ?? "", newArticle: article)
                tableViewArticles.reloadData()
                return;
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ArticlesDetailViewController()
        vc.articlesModelElement = articles?[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
