//
//  AppError.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import Foundation

/// Application-wide error types
enum AppError: LocalizedError {
    case cameraPermissionDenied
    case cameraNotAvailable
    case photoCaptureFailed(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .cameraPermissionDenied:
            return "Camera permission is required to capture photos"
        case .cameraNotAvailable:
            return "Camera is not available on this device"
        case .photoCaptureFailed(let reason):
            return "Failed to capture photo: \(reason)"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}
