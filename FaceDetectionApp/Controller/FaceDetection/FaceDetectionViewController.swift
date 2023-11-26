//
//  FaceDetectionViewController.swift
//  FaceDetectionApp
//
//  Created by Utku Çetinkaya on 26.11.2023.
//

import UIKit
import AVFoundation
import Vision

final class FaceDetectionViewController: UIViewController {

    // MARK: - Variables
    private var drawings: [CAShapeLayer] = []
    
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let captureSession = AVCaptureSession()
    
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCameraInput()
        showCameraFeed()
        
        getCameraFrames()
        captureSession.startRunning()
        setNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer.frame = view.frame
    }
    
    // MARK: - Set Navigation Bar
    private func setNavigationBar() {
        
        if #available(iOS 16, *) {
            navigationItem.style = .editor
        }
        navigationItem.title = NSLocalizedString("Face Detection", comment: "Camera view title")
    }
    
    // MARK: - Add Camera
    private func addCameraInput() {
        // Kamerayi ekle
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            fatalError("No camera detected. Please use a real camera, not a simulator.")
        }

        let cameraInput = try! AVCaptureDeviceInput(device: device)
        captureSession.addInput(cameraInput)
    }
    
    // MARK: - Show Camera
    private func showCameraFeed() {
        // Kamera beslemesini goster
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
    }
    
    // MARK: - Camera Frames
    private func getCameraFrames() {
        // Kameradan kareleri al
        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        
        captureSession.addOutput(videoDataOutput)
        
        guard let connection = videoDataOutput.connection(with: .video), connection.isVideoOrientationSupported else {
            return
        }
        
        connection.videoOrientation = .portrait
    }
    
    // MARK: - Detect Face
    private func detectFace(image: CVPixelBuffer) {
        // Yuzleri algila
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { vnRequest, error in
            DispatchQueue.main.async {
                if let results = vnRequest.results as? [VNFaceObservation], results.count > 0 {
                    self.showToast(message: "✅ Detected \(results.count) faces!")
                    self.handleFaceDetectionResults(observedFaces: results)
                } else {
                    self.showToast(message: "❌ No face was detected")
                    self.clearDrawings()
                }
            }
        }
        
        let imageResultHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageResultHandler.perform([faceDetectionRequest])
    }

    // MARK: - Handle Face Detection
    private func handleFaceDetectionResults(observedFaces: [VNFaceObservation]) {
        clearDrawings()

        // Bu işlev, tespit edilen yüzlerin çerçevelerini çizer.
        let facesBoundingBoxes: [CAShapeLayer] = observedFaces.map({ (observedFace: VNFaceObservation) -> CAShapeLayer in

            let faceBoundingBoxOnScreen = previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
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
        })

        facesBoundingBoxes.forEach { faceBoundingBox in
            view.layer.addSublayer(faceBoundingBox)
            drawings = facesBoundingBoxes
        }
    }
    
    // MARK: - Clear Drawings
    private func clearDrawings() {
        // Cizimleri temizler
        drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension FaceDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("Unable to get image from the sample buffer")
            return
        }
        
        detectFace(image: frame)
    }
}
