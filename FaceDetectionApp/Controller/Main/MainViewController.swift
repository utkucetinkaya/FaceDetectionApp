//
//  MainViewController.swift
//  FaceDetectionApp
//
//  Created by Utku Çetinkaya on 26.11.2023.
//

import UIKit

final class MainViewController: UIViewController {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
    }
    
    // MARK: - Set Navigation Bar
    private func setNavigationBar() {
        
        if #available(iOS 16, *) {
            navigationItem.style = .navigator
        }
        navigationItem.title = NSLocalizedString("Face Detection", comment: "Camera view title")
        navigationItem.backButtonTitle = ""
    }
    
    @IBAction func goToCameraPressed(_ sender: Any) {
        
        let vc = FaceDetectionViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
