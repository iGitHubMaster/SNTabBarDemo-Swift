# SNTabBarDemo-Swift
Cool TabBar

## How To Use

```
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

```

![CoolTabBar](https://user-images.githubusercontent.com/7598376/149181314-1c7557a0-fab2-45f5-a2f4-91035bd1e2ff.gif)
