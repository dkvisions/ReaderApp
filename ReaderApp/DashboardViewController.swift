//
//  ViewController.swift
//  ReaderApp
//
//  Created by Rahul on 12/09/25.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var buttonHome: UIButton!
    @IBOutlet weak var buttonBookmark: UIButton!
    
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var buttonDarkModeSwitch: UISwitch!
    
    var articlesViewController: ArticlesViewController!
    var savedArticlesViewController: SavedArticalesViewController!
    
    
    
    var currentViewController: UIViewController!
    
    var buttons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttons = [buttonHome, buttonBookmark]
        setUpUI()
        buttonAddTapped(buttonHome)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let isDark = traitCollection.userInterfaceStyle == .dark
        buttonDarkModeSwitch.setOn(isDark, animated: true)
        updateForCurrentInterfaceStyle()
    }
    
    func setUpUI() {
        
        buttonDarkModeSwitch.addTarget(self, action: #selector(switchDarkModeSlided), for: .valueChanged)
        for (index, button) in buttons.enumerated() {
            button.layer.cornerRadius = 8
            button.clipsToBounds = true
            button.tag = index
            button.addTarget(self, action: #selector(buttonAddTapped), for: .touchUpInside)
        }
        
    }
    
    private func updateForCurrentInterfaceStyle() {
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            let isDark = traitCollection.userInterfaceStyle == .dark
            buttonDarkModeSwitch.setOn(isDark, animated: true)
            window.overrideUserInterfaceStyle = isDark ? .dark : .light
        }
    }
    
    @objc func switchDarkModeSlided(_ sender: UISwitch) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.overrideUserInterfaceStyle = sender.isOn ? .dark : .light
        }
    }
    
    @objc func buttonAddTapped(_ sender: UIButton) {
        
        if sender.tag == 0 {
            if articlesViewController == nil {
                articlesViewController = ArticlesViewController()
            }
            showSelectedController(vc: articlesViewController)
        } else if sender.tag == 1 {
            if savedArticlesViewController == nil {
                savedArticlesViewController = SavedArticalesViewController()
            }
            showSelectedController(vc: savedArticlesViewController)
        }
        
        buttons.forEach({ button in
            if button.tag == sender.tag {
                button.setTitleColor(.orange, for: .normal)
                button.tintColor = .orange
            } else {
                button.setTitleColor(UIColor(named: "WhiteBlue"), for: .normal)
                button.tintColor = UIColor(named: "WhiteBlue")
                
            }
        })
    }
    
    func showSelectedController(vc: UIViewController) {
        if let currentVC = currentViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        addChild(vc)
        viewContainer.addSubview(vc.view)
        
        addConstraintsTBLR(parent: viewContainer, child: vc.view)
        vc.didMove(toParent: self)
        currentViewController = vc
    }
    
    func addConstraintsTBLR(parent: UIView, child: UIView, topValue: CGFloat = 0, bottomValue: CGFloat = 0) {
        
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: child, attribute: .leading, relatedBy: .equal, toItem: parent, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: child, attribute: .trailing, relatedBy: .equal, toItem: parent, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: child, attribute: .top, relatedBy: .equal, toItem: parent, attribute: .top, multiplier: 1, constant: topValue).isActive = true
        
        NSLayoutConstraint(item: child, attribute: .bottom, relatedBy: .equal, toItem: parent, attribute: .bottom, multiplier: 1, constant: bottomValue).isActive = true
    }
    
}



