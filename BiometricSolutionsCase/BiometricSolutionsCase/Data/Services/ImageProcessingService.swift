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
    
    //MARK: - Hair mask extraction
    
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
    
    //MARK: - Detect eyes
    
    func detectEyes(in image: UIImage) async throws -> EyeDetectionResult {
        guard let cgImage = image.cgImage else {
            throw AppError.imageProcessingFailed("Failed to get CGImage from UIImage")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectFaceLandmarksRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: AppError.imageProcessingFailed("Face detection failed: \(error.localizedDescription)"))
                    return
                }
                
                guard let observations = request.results as? [VNFaceObservation],
                      let faceObservation = observations.first else {
                    continuation.resume(returning: EyeDetectionResult(
                        status: .noEyesDetected,
                        leftEye: nil,
                        rightEye: nil,
                        distanceInPixels: nil,
                        faceRect: nil
                    ))
                    return
                }
                
                // Get face landmarks
                guard let landmarks = faceObservation.landmarks else {
                    continuation.resume(returning: EyeDetectionResult(
                        status: .noEyesDetected,
                        leftEye: nil,
                        rightEye: nil,
                        distanceInPixels: nil,
                        faceRect: self.denormalizeRect(faceObservation.boundingBox, imageSize: CGSize(width: cgImage.width, height: cgImage.height))
                    ))
                    return
                }
                
                // Extract eye positions
                let leftEyePosition = self.getEyePosition(from: landmarks.leftPupil, in: faceObservation.boundingBox, imageSize: CGSize(width: cgImage.width, height: cgImage.height))
                let rightEyePosition = self.getEyePosition(from: landmarks.rightPupil, in: faceObservation.boundingBox, imageSize: CGSize(width: cgImage.width, height: cgImage.height))
                
                // Determine status and calculate distance
                let status: EyeDetectionResult.Status
                let distanceInPixels: CGFloat?
                
                if let leftEye = leftEyePosition, let rightEye = rightEyePosition {
                    status = .bothEyesDetected
                    distanceInPixels = leftEye.distance(to: rightEye)
                } else if leftEyePosition != nil || rightEyePosition != nil {
                    status = .oneEyeDetected
                    distanceInPixels = nil
                } else {
                    status = .noEyesDetected
                    distanceInPixels = nil
                }
                
                let faceRect = self.denormalizeRect(faceObservation.boundingBox, imageSize: CGSize(width: cgImage.width, height: cgImage.height))
                
                continuation.resume(returning: EyeDetectionResult(
                    status: status,
                    leftEye: leftEyePosition,
                    rightEye: rightEyePosition,
                    distanceInPixels: distanceInPixels,
                    faceRect: faceRect
                ))
            }
            
            request.revision = VNDetectFaceLandmarksRequestRevision3
            request.constellation = .constellation76Points
            
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: self.cgImageOrientation(from: image.imageOrientation))
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: AppError.imageProcessingFailed("Failed to perform face detection: \(error.localizedDescription)"))
            }
        }
    }
    
    private func getEyePosition(from eyeRegion: VNFaceLandmarkRegion2D?, in faceBoundingBox: CGRect, imageSize: CGSize) -> EyeDetectionResult.EyePosition? {
        guard let eyeRegion = eyeRegion,
              eyeRegion.pointCount > 0 else { return nil }
        
        // Calculate the center of all eye points
        var sumX: CGFloat = 0
        var sumY: CGFloat = 0
        
        for i in 0..<eyeRegion.pointCount {
            let point = eyeRegion.normalizedPoints[i]
            sumX += CGFloat(point.x)
            sumY += CGFloat(point.y)
        }
        
        let centerX = sumX / CGFloat(eyeRegion.pointCount)
        let centerY = sumY / CGFloat(eyeRegion.pointCount)
        
        // Convert normalized coordinates to image coordinates
        // The normalized points are relative to the face bounding box
        let denormalizedFaceRect = denormalizeRect(faceBoundingBox, imageSize: imageSize)
        
        let eyeX = denormalizedFaceRect.origin.x + (centerX * denormalizedFaceRect.width)
        let eyeY = denormalizedFaceRect.origin.y + (centerY * denormalizedFaceRect.height)
        
        return EyeDetectionResult.EyePosition(x: eyeX, y: eyeY)
    }
    
    private func denormalizeRect(_ normalizedRect: CGRect, imageSize: CGSize) -> CGRect {
        // Vision framework uses normalized coordinates (0-1) with origin at bottom-left
        // Convert to UIImage coordinates with origin at top-left
        return CGRect(
            x: normalizedRect.origin.x * imageSize.width,
            y: (1 - normalizedRect.origin.y - normalizedRect.height) * imageSize.height,
            width: normalizedRect.width * imageSize.width,
            height: normalizedRect.height * imageSize.height
        )
    }
    
    private func cgImageOrientation(from uiImageOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch uiImageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
