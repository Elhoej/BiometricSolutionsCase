//
//  DetectEyesUseCase.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import Foundation
import UIKit

/// Protocol for eye detection use case
protocol DetectEyesUseCaseProtocol {
    /// Detects eyes in the given image and calculates distance if both eyes are found
    func execute(in image: UIImage) async throws -> EyeDetectionResult
}

/// Use case for detecting eyes in an image
final class DetectEyesUseCase: DetectEyesUseCaseProtocol {
    private let imageProcessingService: ImageProcessingProtocol
    
    init(imageProcessingService: ImageProcessingProtocol) {
        self.imageProcessingService = imageProcessingService
    }
    
    func execute(in image: UIImage) async throws -> EyeDetectionResult {
        return try await imageProcessingService.detectEyes(in: image)
    }
}
