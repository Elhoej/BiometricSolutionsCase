//
//  CameraService.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import Foundation
import AVFoundation
import UIKit

/// Implementation of camera service using AVFoundation
final class CameraService: NSObject, CameraServiceProtocol {
    private let captureSession = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var captureDevice: AVCaptureDevice?
    
    private var photoContinuation: CheckedContinuation<UIImage, Error>?
    private var lastCapturedPhoto: AVCapturePhoto?
    
    override init() {
        super.init()
    }
    
    // MARK: - CameraServiceProtocol
    
    func authorizationStatus() -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    func requestPermission() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }
    
    func setupCamera() async throws {
        // Configure capture session
        captureSession.beginConfiguration()
        
        // Get camera device
        guard let device = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) else {
            throw AppError.cameraNotAvailable
        }
        captureDevice = device
        
        // Create input
        let input = try AVCaptureDeviceInput(device: device)
        
        guard captureSession.canAddInput(input) else {
            throw AppError.cameraNotAvailable
        }
        
        captureSession.addInput(input)
        
        // Create photo output and set quality vs speed prio
        let output = AVCapturePhotoOutput()
        output.maxPhotoQualityPrioritization = .speed
        
        guard captureSession.canAddOutput(output) else {
            throw AppError.cameraNotAvailable
        }
        
        photoOutput = output
        captureSession.addOutput(output)
        
        captureSession.commitConfiguration()
    }
    
    func startSession() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
                continuation.resume()
            }
        }
    }
    
    func stopSession() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.stopRunning()
                continuation.resume()
            }
        }
    }
    
    func capturePhoto() async throws -> UIImage {
        guard let photoOutput = photoOutput else {
            throw AppError.cameraNotAvailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.photoContinuation = continuation
            
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .auto
            
            settings.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliveryEnabled
            settings.isPortraitEffectsMatteDeliveryEnabled = photoOutput.isPortraitEffectsMatteDeliveryEnabled
            settings.enabledSemanticSegmentationMatteTypes = photoOutput.enabledSemanticSegmentationMatteTypes
            
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    // MARK: - Public Methods
    
    /// Creates a preview layer for the camera
    func makePreviewLayer() -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        self.videoPreviewLayer = layer
        return layer
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            photoContinuation?.resume(throwing: AppError.photoCaptureFailed(error.localizedDescription))
            photoContinuation = nil
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            photoContinuation?.resume(throwing: AppError.photoCaptureFailed("Failed to process image data"))
            photoContinuation = nil
            return
        }
        
        // Store the photo for later matte extraction
        lastCapturedPhoto = photo
        
        photoContinuation?.resume(returning: image)
        photoContinuation = nil
    }
}
