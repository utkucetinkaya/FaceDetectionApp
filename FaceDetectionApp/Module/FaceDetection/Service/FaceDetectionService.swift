//
//  FaceDetectionService.swift
//  FaceDetectionApp
//
//  Created by Utku Çetinkaya on 26.11.2023.
//

import UIKit
import AVFoundation
import Vision

// MARK: - Face Detection Service Protocol
protocol FaceDetectionServiceDelegate: AnyObject {
    func didDetectFaces(_ faces: [VNFaceObservation])
    func didFailToDetectFaces()
}

// MARK: - Face Detection View Model Protocol
protocol FaceDetectionViewModelDelegate: AnyObject {
    func didReceiveFaceDetectionResults(_ results: [CAShapeLayer])
    func didFailToReceiveFaceDetectionResults()
    func didReceiveMessage(_ message: String)
}

// MARK: - Face Detection Service
final class FaceDetectionService {
    
    weak var delegate: FaceDetectionServiceDelegate?
    
    // MARK: - Detect Face
    func detectFace(image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { vnRequest, error in
            DispatchQueue.main.async {
                if let results = vnRequest.results as? [VNFaceObservation], results.count > 0 {
                    self.delegate?.didDetectFaces(results)
                } else {
                    self.delegate?.didFailToDetectFaces()
                }
            }
        }
        let imageResultHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageResultHandler.perform([faceDetectionRequest])
    }
    
    // MARK: - CreateFaceBoundingShape
    func createFaceBoundingBoxShape(for face: VNFaceObservation, in view: AVCaptureVideoPreviewLayer, using previewLayer: AVCaptureVideoPreviewLayer) -> CAShapeLayer {
        // Bu işlev, tespit edilen yüzlerin çerçevelerini çizer.
        let faceBoundingBoxOnScreen = previewLayer.layerRectConverted(fromMetadataOutputRect: face.boundingBox)
        let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
        let faceBoundingBoxShape = CAShapeLayer()
        
        // Box ozellikleri belirler
        faceBoundingBoxShape.path = faceBoundingBoxPath
        faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
        faceBoundingBoxShape.strokeColor = UIColor.faceBoxColor.cgColor
        
        // Animasyon ekler
        let glowAnimation = CABasicAnimation(keyPath: "opacity")
        glowAnimation.fromValue = 1.0
        glowAnimation.toValue = 0.0
        glowAnimation.autoreverses = true
        glowAnimation.repeatCount = .infinity
        glowAnimation.duration = 0.5
        faceBoundingBoxShape.add(glowAnimation, forKey: "glow")
        
        return faceBoundingBoxShape
    }
}
