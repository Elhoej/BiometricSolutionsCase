//
//  ImageProcessingService.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import Foundation
import UIKit
import CoreImage
import Vision

/// Implementation of image processing service using Portrait Effects Matte
final class ImageProcessingService: ImageProcessingProtocol {
    private let context = CIContext()
    private let cameraService: CameraService
    
    init(cameraService: CameraService) {
        self.cameraService = cameraService
    }
    
    func extractHairSegmentation(from image: UIImage) async throws -> HairSegmentationResult {
        // Get the portrait effects matte from the camera service
        guard let hairMatteCIImage = cameraService.getSegmentationMatteForHair() else {
            throw AppError.noHairDetected
        }
        
        // Process the hair matte
        let processedMask = try processHairMatte(
            matteCIImage: hairMatteCIImage,
            originalImage: image
        )
        
        return HairSegmentationResult(maskImage: processedMask)
    }
    
    private func processHairMatte(
        matteCIImage: CIImage,
        originalImage: UIImage
    ) throws -> UIImage {
        // Convert original UIImage to CIImage to get proper orientation handling
        guard let originalCIImage = CIImage(image: originalImage) else {
            throw AppError.imageProcessingFailed("Failed to create CIImage from original")
        }
        
        // The originalCIImage already has the correct orientation applied
        let targetSize = originalCIImage.extent.size
        
        // Scale the matte to match the oriented original image
        let scaleX = targetSize.width / matteCIImage.extent.width
        let scaleY = targetSize.height / matteCIImage.extent.height
        
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        let scaledMatte = matteCIImage.transformed(by: transform)
        
        // Convert to UIImage
        guard let cgImage = context.createCGImage(scaledMatte, from: scaledMatte.extent) else {
            throw AppError.imageProcessingFailed("Failed to create mask image")
        }
        
        return UIImage(cgImage: cgImage, scale: originalImage.scale, orientation: originalImage.imageOrientation)
    }
}
