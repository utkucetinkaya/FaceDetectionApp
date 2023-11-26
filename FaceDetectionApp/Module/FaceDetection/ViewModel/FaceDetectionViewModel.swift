//
//  FaceDetectionViewModel.swift
//  FaceDetectionApp
//
//  Created by Utku Çetinkaya on 26.11.2023.
//

import UIKit
import AVFoundation
import Vision

// MARK: - FaceDetectionViewModel
final class FaceDetectionViewModel: NSObject {
    
    // MARK: - Properties
    weak var delegate: FaceDetectionViewModelDelegate?
    private let faceDetectionService = FaceDetectionService()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    
    // MARK: - Init
    override init() {
        super.init()
        faceDetectionService.delegate = self
    }
    
    // MARK: - AddCameraInput
    func addCameraInput() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            fatalError("No camera detected. Please use a real camera, not a simulator.")
        }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        captureSession.addInput(cameraInput)
    }
    
    // MARK: - GetCameraFrames
    func getCameraFrames() {
        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        captureSession.addOutput(videoDataOutput)
        guard let connection = videoDataOutput.connection(with: .video), connection.isVideoOrientationSupported else {
            return
        }
        connection.videoOrientation = .portrait
    }
    
    // MARK: - StartCaptureSession
    func startCaptureSession() {
         captureSession.startRunning()
     }
     
    // MARK: - GetPreviewLayer
     func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
         return previewLayer
     }
}

// MARK: - FaceDetectionServiceDelegate
extension FaceDetectionViewModel: FaceDetectionServiceDelegate {
    func didDetectFaces(_ faces: [VNFaceObservation]) {
        delegate?.didReceiveMessage("✅ Detected \(faces.count) faces!")
        let faceBoundingBoxShapes = faces.map {
            faceDetectionService.createFaceBoundingBoxShape(
            for: $0,
            in: previewLayer,
            using: previewLayer)
        }
        delegate?.didReceiveFaceDetectionResults(faceBoundingBoxShapes)
    }
    
    func didFailToDetectFaces() {
        delegate?.didReceiveMessage("❌ No face was detected")
        delegate?.didFailToReceiveFaceDetectionResults()
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension FaceDetectionViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("Unable to get image from the sample buffer")
            return
        }
        faceDetectionService.detectFace(image: frame)
    }
}
