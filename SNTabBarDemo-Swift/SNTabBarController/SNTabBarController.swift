//
//  SNTabBarController.swift
//  SNTabBarDemo-Swift
//
//  Created by ShawnWong on 2022/1/11.
//

import UIKit

class SNTabBarController: UITabBarController, SNTabBarDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedIndex = 0;
        setupTabBar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        for subView in self.tabBar.subviews {
            if !subView.isKind(of: SNTabBar.classForCoder()) {
                subView.removeFromSuperview()
            }
        }
    }

// MARK: - setup
    private func setupTabBar() {
        if self.tabBar.items!.count > 0 {
            
            var itemsArr = [SNTabBarItem]()
            for item: UITabBarItem in self.tabBar.items! {
                let newItem = SNTabBarItem.init(image: item.image!, selectedImage: item.selectedImage!)
                itemsArr.append(newItem)
            }
            
            let newTabBar = SNTabBar.init(frame: self.tabBar.bounds, nativeTabBar: self.tabBar)
            newTabBar.delegate = self
            newTabBar.selectedIndex = self.selectedIndex
            newTabBar.items = itemsArr
//            newTabBar.barTintColor = UIColor.red
//            newTabBar.backgroudImage = UIImage.init(named: "bg_image");
            newTabBar.indicatorColors = [UIColor.init(_colorLiteralRed: 0, green: 1, blue: 1, alpha: 1.0),
                                         UIColor.init(_colorLiteralRed: 0.92, green: 0.42, blue: 0.67, alpha: 1.0)]
            
            self.tabBar.addSubview(newTabBar);
        }
    }

// MARK: - SNTabBarDelegate
    func sn_tabBarDidSelectItem(tabBar: SNTabBar, tabBarItem: SNTabBarItem) {
        self.selectedIndex = tabBar.selectedIndex
    }
}
