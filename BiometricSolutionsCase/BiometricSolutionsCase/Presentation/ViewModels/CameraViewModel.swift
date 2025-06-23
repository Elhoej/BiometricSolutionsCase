//
//  CameraViewModel.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

/// ViewModel for camera view
@MainActor
final class CameraViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var error: AppError?
    @Published var showingResult = false
    @Published var analyzedPhoto: AnalyzedPhoto?
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    
    // MARK: - Dependencies
    private let capturePhotoUseCase: CapturePhotoUseCaseProtocol
    private let cameraService: CameraServiceProtocol
    private let permissionManager: PermissionManager
    private let extractHairMaskUseCase: ExtractHairMaskUseCaseProtocol
    private let detectEyesUseCase: DetectEyesUseCaseProtocol
    
    // MARK: - Initialization
    init(
        capturePhotoUseCase: CapturePhotoUseCaseProtocol,
        cameraService: CameraServiceProtocol,
        permissionManager: PermissionManager,
        extractHairMaskUseCase: ExtractHairMaskUseCaseProtocol,
        detectEyesUseCase: DetectEyesUseCaseProtocol
    ) {
        self.capturePhotoUseCase = capturePhotoUseCase
        self.cameraService = cameraService
        self.permissionManager = permissionManager
        self.extractHairMaskUseCase = extractHairMaskUseCase
        self.detectEyesUseCase = detectEyesUseCase
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// Initializes the camera
    func initializeCamera() async {
        await permissionManager.checkCameraPermission()
        
        guard permissionManager.isCameraAuthorized else { return }
        
        do {
            try await cameraService.setupCamera()
            await cameraService.startSession()
            cameraService.configureSessionForDepth()
        } catch {
            self.error = error as? AppError ?? .unknown(error)
        }
    }
    
    /// Requests camera permission
    func requestCameraPermission() async {
        _ = await permissionManager.requestCameraPermission()
    }
    
    /// Captures a photo and processes it
    func capturePhoto() async {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            // Capture photo
            let photo = try await capturePhotoUseCase.execute()
            
            // Extract hair mask
            var hairMask = try await extractHairMaskUseCase.execute(from: photo)
            
            // Detect eyes
            let eyeDetectionResult = try await detectEyesUseCase.execute(in: photo.image)
            
            // Create hair mask object
            analyzedPhoto = AnalyzedPhoto(
                originalPhoto: photo,
                hairMask: hairMask,
                eyeDetectionResult: eyeDetectionResult
            )
            
            // Update state
            analyzedPhoto = analyzedPhoto
            showingResult = true
        } catch let appError as AppError {
            self.error = appError
        } catch {
            self.error = .unknown(error)
        }
    }
    
    /// Dismisses the result view
    func dismissResult() {
        showingResult = false
        analyzedPhoto = nil
    }
    
    /// Stops the camera session
    func stopCamera() async {
        await cameraService.stopSession()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Observe permission changes
        permissionManager.$cameraPermissionStatus
            .assign(to: &$cameraPermissionStatus)
    }
}
