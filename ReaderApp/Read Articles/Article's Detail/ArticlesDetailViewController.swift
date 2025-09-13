//
//  ArticlesDetailViewController.swift
//  ReaderApp
//
//  Created by Rahul on 13/09/25.
//

import UIKit

class ArticlesDetailViewController: UIViewController {

    @IBOutlet weak var viewProfileContainer: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var articleStackView: UIStackView!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labelAuthorName: UILabel!
    @IBOutlet weak var labelPublishedDate: UILabel!
    @IBOutlet weak var buttonAddBookmark: UIButton!
    @IBOutlet weak var imageViewBlogsImage: UIImageView!
    @IBOutlet weak var labelBlogsTitle: UILabel!
    @IBOutlet weak var textViewContents: UITextView!
    
    @IBOutlet weak var viewContainer: UIView!
    
    var articlesModelElement: ArticlesModelElement?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI(data: articlesModelElement)
    }
    
    func setUpUI(data: ArticlesModelElement?) {
        
        buttonAddBookmark.isHidden = true
        viewProfileContainer.layer.cornerRadius = 8
        imageViewBlogsImage.layer.cornerRadius = 8
        viewProfileContainer.layer.borderWidth = 0.3
        imageViewProfile.layer.cornerRadius = 35
        viewProfileContainer.layer.borderColor = UIColor.systemGray2.cgColor
        
        imageViewProfile.sd_setImage(with: URL(string: data?.urlToImage ?? ""))
        imageViewBlogsImage.sd_setImage(with: URL(string: data?.urlToImage ?? ""))
        labelTitle.text = data?.title
        labelBlogsTitle.text = data?.description
        textViewContents.text = data?.content
        textViewContents.isEditable = false
        labelAuthorName.text = data?.author
        labelPublishedDate.text = AppCommonFunctions.formateDate(dateString: data?.publishedAt ?? "")
    }

}

