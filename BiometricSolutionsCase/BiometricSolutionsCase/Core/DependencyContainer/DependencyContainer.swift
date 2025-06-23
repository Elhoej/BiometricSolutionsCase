//
//  DependencyContainer.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import Foundation
import SwiftUI

/// Dependency injection container for the app
@MainActor
final class DependencyContainer: ObservableObject {
    // MARK: - Singleton
    static let shared = DependencyContainer()
    
    // MARK: - Services
    lazy var permissionManager = PermissionManager()
    lazy var cameraService = CameraService()
    lazy var imageProcessingService: ImageProcessingProtocol = {
        return ImageProcessingService(cameraService: cameraService)
    }()
    
    // MARK: - Use Cases
    lazy var capturePhotoUseCase: CapturePhotoUseCaseProtocol = {
        return CapturePhotoUseCase(cameraService: cameraService)
    }()
    
    lazy var extractHairMaskUseCase: ExtractHairMaskUseCaseProtocol = {
        return ExtractHairMaskUseCase(imageProcessor: imageProcessingService)
    }()
    
    lazy var detectEyesUseCase: DetectEyesUseCaseProtocol = {
        return DetectEyesUseCase(imageProcessingService: imageProcessingService)
    }()
    
    // MARK: - ViewModels
    func makeCameraViewModel() -> CameraViewModel {
        return CameraViewModel(
            capturePhotoUseCase: capturePhotoUseCase,
            cameraService: cameraService,
            permissionManager: permissionManager,
            extractHairMaskUseCase: extractHairMaskUseCase,
            detectEyesUseCase: detectEyesUseCase
        )
    }
    
    private init() {}
}
