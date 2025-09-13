//
//  MenuCollectionCell.swift
//  ReaderApp
//
//  Created by Rahul on 13/09/25.
//

import UIKit

class MenuCollectionCell: UICollectionViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelMenu: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func configureCell(_ selectedIndex: Int, _ index: Int) {
        viewContainer.clipsToBounds = true
        viewContainer.layer.cornerRadius = 8
        labelMenu.text = Constants.newsSources[index].sourceName
        labelMenu.font = .systemFont(ofSize: selectedIndex == index ? 14 : 12, weight: selectedIndex == index ? .bold : .regular)
        labelMenu.textColor = selectedIndex == index ? .orange : UIColor(named: "WhiteBlue")
     
    }

}
