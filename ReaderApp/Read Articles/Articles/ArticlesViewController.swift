//
//  ArticlesViewController.swift
//  ReaderApp
//
//  Created by Rahul on 13/09/25.
//

import UIKit


extension UITableViewCell {
    static var reuseIdentifier: String {
        return "\(self)"
    }
}

extension UICollectionViewCell {
    static var reuseIdentifier: String {
        return "\(self)"
    }
}


import UIKit

class ArticlesViewController: UIViewController {
    
    @IBOutlet weak var tableViewArticle: UITableView!
    @IBOutlet weak var collectionViewMenu: UICollectionView!
    
    lazy var viewModel: ArticlesViewModel? = ArticlesViewModel()
    
    private let loader = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    var selectedMenu = 0
    
    private let searchBar = UISearchBar()
    private var filteredArticles: [ArticlesModelElement] = []
    private var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSearchBar()
        setUpTableView()
        setUpCollection()
        setupLoader()
        setupRefreshControl()
        initialSetUp()
        
        print(CoreDataManager.shared.fetchArticles().count)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel?.fetchArticles(source: Constants.newsSources[selectedMenu].sourceKey)
        resetSearch()
    }
    
    
    private func setUpSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search Articles"
        searchBar.sizeToFit()
        tableViewArticle.tableHeaderView = searchBar
    }
    
    private func setupLoader() {
        loader.center = view.center
        loader.hidesWhenStopped = true
        view.addSubview(loader)
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Articles...")
        refreshControl.addTarget(self, action: #selector(refreshArticles), for: .valueChanged)
        tableViewArticle.refreshControl = refreshControl
    }
    
    @objc private func refreshArticles() {
        viewModel?.fetchArticles(source: Constants.newsSources[selectedMenu].sourceKey)
        resetSearch()
    }
    
    func initialSetUp() {
        viewModel?.completion = { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch status {
                case .loading(let show):
                    if show {
                        if !self.refreshControl.isRefreshing {
                            self.loader.startAnimating()
                        }
                    } else {
                        self.loader.stopAnimating()
                        self.refreshControl.endRefreshing()
                    }
                    
                case .success:
                    self.tableViewArticle.reloadData()
                    self.refreshControl.endRefreshing()
                    
                case .failed(let error):
                    self.loader.stopAnimating()
                    self.refreshControl.endRefreshing()
                    switch error  {
                    case .notReachable:
                        let articles = CoreDataManager.shared.fetchArticles()
                        self.viewModel?.articlesModelData = ArticlesModel(status: "false", totalResults: 10, articles: articles)
                        
                        AppCommonFunctions.showToast(view: self.view, "No Internet Connection")
                    case .decodingError:
                        AppCommonFunctions.showToast(view: self.view, "Failed to Decode Data")
                    case .noDataFound:
                        AppCommonFunctions.showToast(view: self.view, "No Articles Found")
                    case .errorWithStatusCode(let code):
                        AppCommonFunctions.showToast(view: self.view, "Error: Status Code \(code)")
                    }
                }
            }
        }
    }
    
}

// MARK: - TableView
extension ArticlesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func setUpTableView() {
        let nib = UINib(nibName: ArticlesListTableViewCell.reuseIdentifier, bundle: nil)
        tableViewArticle.register(nib, forCellReuseIdentifier: ArticlesListTableViewCell.reuseIdentifier)
        tableViewArticle.delegate = self
        tableViewArticle.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredArticles.count
        } else {
            return viewModel?.articlesModelData?.articles?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticlesListTableViewCell.reuseIdentifier) as? ArticlesListTableViewCell else {
            return UITableViewCell()
        }
        
        let article = isSearching ? filteredArticles[indexPath.row] : viewModel?.articlesModelData?.articles?[indexPath.row]
        
        cell.buttonAddBookmark.tag = indexPath.row
        cell.buttonAddBookmark.addTarget(self, action: #selector(bookMarkTapped), for: .touchUpInside)
        cell.configureCell(data: article)
        return cell
    }
    
    @objc func bookMarkTapped(_ sender: UIButton) {
        if isSearching {
            var article = filteredArticles[sender.tag]
            let isBookMarked = article.isBookMark == true ? false : true
            article.isBookMark = isBookMarked
            filteredArticles[sender.tag].isBookMark = isBookMarked
            CoreDataManager.shared.updateArticle(publishedAt: article.publishedAt ?? "", newArticle: article)
            
        } else {
            if var article = viewModel?.articlesModelData?.articles?[sender.tag] {
                let isBookMarked = article.isBookMark == true ? false : true
                article.isBookMark = isBookMarked
                viewModel?.articlesModelData?.articles?[sender.tag].isBookMark = isBookMarked
                CoreDataManager.shared.updateArticle(publishedAt: article.publishedAt ?? "", newArticle: article)
            }
        }
        
        tableViewArticle.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ArticlesDetailViewController()
        vc.articlesModelElement = isSearching ? filteredArticles[indexPath.row] : viewModel?.articlesModelData?.articles?[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - SearchBar
extension ArticlesViewController: UISearchBarDelegate {
    
    func resetSearch() {
        isSearching = false
        filteredArticles.removeAll()
        searchBar.text = ""
        tableViewArticle.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let articles = viewModel?.articlesModelData?.articles else { return }
        
        if searchText.isEmpty {
            isSearching = false
            filteredArticles.removeAll()
        } else {
            isSearching = true
            filteredArticles = articles.filter { $0.title?.lowercased().contains(searchText.lowercased()) ?? false }
        }
        tableViewArticle.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        filteredArticles.removeAll()
        searchBar.text = ""
        tableViewArticle.reloadData()
    }
}

// MARK: - CollectionView
extension ArticlesViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func setUpCollection() {
        let nib = UINib(nibName: MenuCollectionCell.reuseIdentifier, bundle: nil)
        collectionViewMenu.register(nib, forCellWithReuseIdentifier: MenuCollectionCell.reuseIdentifier)
        collectionViewMenu.delegate = self
        collectionViewMenu.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Constants.newsSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCollectionCell.reuseIdentifier, for: indexPath) as? MenuCollectionCell else {
            return UICollectionViewCell()
        }
        cell.configureCell(selectedMenu, indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMenu = indexPath.row
        viewModel?.fetchArticles(source: Constants.newsSources[selectedMenu].sourceKey)
        resetSearch()
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
}
