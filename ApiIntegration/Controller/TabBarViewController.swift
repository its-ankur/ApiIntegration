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
        
        // Hide the back button
        self.navigationItem.hidesBackButton = true
        
        // Add swipe gesture recognizers for left and right swipes
        addSwipeGestures()
        
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        // Ensure the navigation bar is shown again when navigating away
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar and back button when the view appears
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationItem.hidesBackButton = true
    }
    
    // Add swipe gestures for left and right
    private func addSwipeGestures() {
        // Swipe Left Gesture
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        // Swipe Right Gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    // Handle swipe gestures
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if selectedIndex < (viewControllers?.count ?? 0) - 1 {
                selectedIndex += 1  // Move to the next tab
            }
        } else if gesture.direction == .right {
            if selectedIndex > 0 {
                selectedIndex -= 1  // Move to the previous tab
            }
        }
    }
    
}

