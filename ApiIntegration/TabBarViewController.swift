//
//  TabBarViewController.swift
//  ApiIntegration
//
//  Created by Ankur on 07/10/24.
//

import Foundation
import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide the navigation bar for this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Ensure the navigation bar is shown again when navigating away
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

