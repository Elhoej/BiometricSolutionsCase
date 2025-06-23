//
//  ExtractHairMaskUseCase.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import Foundation
import UIKit

/// Protocol for hair mask extraction use case
protocol ExtractHairMaskUseCaseProtocol {
    func execute(from photo: CapturedPhoto) async throws -> HairMask
}

/// Use case for extracting hair masks with business logic validation
final class ExtractHairMaskUseCase: ExtractHairMaskUseCaseProtocol {
    private let imageProcessor: ImageProcessingProtocol
    
    init(imageProcessor: ImageProcessingProtocol) {
        self.imageProcessor = imageProcessor
    }
    
    func execute(from photo: CapturedPhoto) async throws -> HairMask {
        // Process the image to extract hair segmentation
        let segmentation = try await imageProcessor.extractHairSegmentation(from: photo.image)
        
        // Create and return the hair mask
        return HairMask(
            originalPhoto: photo,
            maskImage: segmentation.maskImage
        )
    }
}
