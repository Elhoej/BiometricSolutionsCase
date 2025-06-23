//
//  ImageProcessingProtocol.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import Foundation
import UIKit

/// Result of hair segmentation processing
struct HairSegmentationResult {
    let maskImage: UIImage
}

/// Protocol defining image processing capabilities
protocol ImageProcessingProtocol {
    /// Extracts hair segmentation from an image
    func extractHairSegmentation(from image: UIImage) async throws -> HairSegmentationResult
    
    /// Detects eyes in an image and calculates distance if both eyes are found
    func detectEyes(in image: UIImage) async throws -> EyeDetectionResult
}
