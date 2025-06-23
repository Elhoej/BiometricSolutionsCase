//
//  EyeDetectionResult.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import Foundation
import CoreGraphics

/// Represents the result of eye detection in an image
struct EyeDetectionResult {
    /// Status of eye detection
    enum Status {
        case bothEyesDetected
        case oneEyeDetected
        case noEyesDetected
    }
    
    /// Position of an eye in the image
    struct EyePosition {
        let x: CGFloat
        let y: CGFloat
        
        /// Calculate distance to another eye position
        func distance(to other: EyePosition) -> CGFloat {
            let dx = x - other.x
            let dy = y - other.y
            return sqrt(dx * dx + dy * dy)
        }
    }
    
    let status: Status
    let leftEye: EyePosition?
    let rightEye: EyePosition?
    let distanceInPixels: CGFloat?
    let faceRect: CGRect?
    
    /// Computed property for eye distance in a more readable format
    var formattedDistance: String? {
        guard let distance = distanceInPixels else { return nil }
        return String(format: "%.1f pixels", distance)
    }
    
    /// Message to display based on detection status
    var statusMessage: String {
        switch status {
        case .bothEyesDetected:
            return "Both eyes detected"
        case .oneEyeDetected:
            return "Only one eye detected"
        case .noEyesDetected:
            return "No eyes detected"
        }
    }
}
