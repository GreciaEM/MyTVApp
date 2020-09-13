//
//  MainTabBarController.swift
//  MyTVApp
//
//  Created by Grecia Escárcega on 13/09/20.
//  Copyright © 2020 GEM. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override var selectedIndex: Int {
        didSet {
            popToRootViewController(index: selectedIndex)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = tabBarController.viewControllers?.firstIndex(of: viewController) ?? NSNotFound
        popToRootViewController(index: index)
        return true
    }

    func popToRootViewController(index: Int) {
        let sectionNavController = self.viewControllers![index] as? UINavigationController
            sectionNavController?.popToRootViewController(animated: false)
    }
}
