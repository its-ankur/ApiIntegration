//
//  MyVisitsController.swift
//  ApiIntegration
//
//  Created by Ankur on 08/10/24.
//

import Foundation

import UIKit

class MyVisitsController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the navigation bar for this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    @IBAction func fabButtonClicked(_ sender: UIButton) {
        let fabMenu = UIAlertController(title: "Scan Options", message: nil, preferredStyle: .actionSheet)

        fabMenu.addAction(UIAlertAction(title: "QR Code", style: .default, handler: { _ in
            self.navigateToQRCodePage()
        }))

        fabMenu.addAction(UIAlertAction(title: "Bar Code", style: .default, handler: { _ in
            self.navigateToBarCodePage()
        }))

        fabMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Handle popover presentation for iPad to prevent a crash
        if let popoverController = fabMenu.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = sender.frame
            popoverController.permittedArrowDirections = .any
        }

        self.present(fabMenu, animated: true, completion: nil)
    }

    
    func navigateToQRCodePage() {
        let qrScannerVC = storyboard?.instantiateViewController(withIdentifier: "QRScannerViewController") as! QRScannerViewController
        self.navigationController?.pushViewController(qrScannerVC, animated: true)
    }

    func navigateToBarCodePage() {
        let barCodeScannerVC = storyboard?.instantiateViewController(withIdentifier: "BarCodeScannerViewController") as! BarCodeScannerViewController
        self.navigationController?.pushViewController(barCodeScannerVC, animated: true)
    }

    
}
