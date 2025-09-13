//
//  ArticlesListTableViewCell.swift
//  ReaderApp
//
//  Created by Rahul on 13/09/25.
//

import UIKit
import SDWebImage

class ArticlesListTableViewCell: UITableViewCell {

    @IBOutlet weak var viewProfileContainer: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var articleStackView: UIStackView!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labelAuthorName: UILabel!
    @IBOutlet weak var labelPublishedDate: UILabel!
    @IBOutlet weak var buttonAddBookmark: UIButton!
    @IBOutlet weak var imageViewBlogsImage: UIImageView!
    @IBOutlet weak var labelBlogsTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    
    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewContainer.layer.cornerRadius = 16
        viewContainer.clipsToBounds = true
        viewContainer.clipsToBounds = true
        imageViewProfile.layer.cornerRadius = 35
        viewContainer.layer.borderWidth = 0.7
        viewContainer.layer.borderColor = UIColor.systemGray2.cgColor
        
        viewProfileContainer.layer.cornerRadius = 8
        viewProfileContainer.layer.borderWidth = 0.3
        imageViewBlogsImage.layer.cornerRadius = 8
        viewProfileContainer.layer.borderColor = UIColor.systemGray2.cgColor
    }

    func configureCell(data: ArticlesModelElement?) {
        imageViewProfile.sd_setImage(with: URL(string: data?.urlToImage ?? ""))
        imageViewBlogsImage.sd_setImage(with: URL(string: data?.urlToImage ?? ""))
        labelTitle.text = data?.title
        labelBlogsTitle.text = data?.description
        labelDescription.text = data?.content
        buttonAddBookmark.setImage(UIImage(systemName: data?.isBookMark == true ? "bookmark.fill" : "bookmark"), for: .normal)
        buttonAddBookmark.setImage(UIImage(systemName: data?.isBookMark == true ? "bookmark.fill" : "bookmark"), for: .selected)
        labelAuthorName.text = data?.author
        labelPublishedDate.text = AppCommonFunctions.formateDate(dateString: data?.publishedAt ?? "")
    }
    
    
    
}
