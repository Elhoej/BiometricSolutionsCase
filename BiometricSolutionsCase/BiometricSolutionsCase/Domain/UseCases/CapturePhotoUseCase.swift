//
//  CapturePhotoUseCase.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import Foundation
import UIKit

/// Protocol for photo capture use case
protocol CapturePhotoUseCaseProtocol {
    func execute() async throws -> CapturedPhoto
}

/// Use case for capturing photos
final class CapturePhotoUseCase: CapturePhotoUseCaseProtocol {
    private let cameraService: CameraServiceProtocol
    
    init(cameraService: CameraServiceProtocol) {
        self.cameraService = cameraService
    }
    
    func execute() async throws -> CapturedPhoto {
        // Check camera permission
        guard cameraService.authorizationStatus() == .authorized else {
            throw AppError.cameraPermissionDenied
        }
        
        // Capture the photo
        let image = try await cameraService.capturePhoto()
        
        // Create and return the captured photo model
        return CapturedPhoto(image: image)
    }
}
