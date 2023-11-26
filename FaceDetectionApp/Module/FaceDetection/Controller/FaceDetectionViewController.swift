//
//  FaceDetectionViewController.swift
//  FaceDetectionApp
//
//  Created by Utku Çetinkaya on 26.11.2023.
//

import UIKit

final class FaceDetectionViewController: UIViewController {
    
    // MARK: - Variables
    private var drawings: [CAShapeLayer] = []
    private let viewModel = FaceDetectionViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        viewModel.addCameraInput()
        viewModel.getCameraFrames()
        viewModel.startCaptureSession()
        setNavigationBar()
        showCameraFeed()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        viewModel.getPreviewLayer().frame = view.frame
    }
    
    // MARK: - Set Navigation Bar
    private func setNavigationBar() {
        
        if #available(iOS 16, *) {
            navigationItem.style = .editor
        }
        navigationItem.title = NSLocalizedString("Face Detection", comment: "Camera view title")
    }
    
    // MARK: - ShowCamera
    private func showCameraFeed() {
        viewModel.getPreviewLayer().videoGravity = .resizeAspectFill
        view.layer.addSublayer(viewModel.getPreviewLayer())
        viewModel.getPreviewLayer().frame = view.frame
    }
    
    // MARK: - Clear Drawings
    private func clearDrawings() {
        // Cizimleri temizler
        drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
    }
}

// MARK: - FaceDetectionViewModelDelegate
extension FaceDetectionViewController: FaceDetectionViewModelDelegate {
    
    func didReceiveFaceDetectionResults(_ results: [CAShapeLayer]) {
        clearDrawings()
        results.forEach { result in
            view.layer.addSublayer(result)
            drawings.append(result)
        }
    }
    
    func didFailToReceiveFaceDetectionResults() {
        clearDrawings()
    }
    
    func didReceiveMessage(_ message: String) {
        showToast(message: message)
    }
}
